module Arlj
  module Base
    def self.memoize!
      require 'memoist'
      self.extend Memoist
      self.memoize :arlj_sql, :arlj_aggregate_sql
    end

    def arlj(assoc)
      # Example snippet:
      #  LEFT JOIN [assoc]
      #         ON [assoc].source_id = source.id

      joins(arlj_sql(assoc))
    end

    # Example usage:
    #   arlj_aggregate(other, 'count(*)', 'sum(col)' => target_name)
    def arlj_aggregate(assoc, *args)
      # Example snippet:
      #  LEFT JOIN(SELECT source_id, [func]([column]) AS [target_name]
      #              FROM [assoc]
      #             GROUP BY [assoc].source_id) arlj_aggregate_[assoc]
      #         ON [assoc].source_id = source.id

      joins(arlj_aggregate_sql(assoc, *args))
    end

    def arlj_arel(assoc)
      refl = reflect_on_association(assoc)
      arlj_left_join_arel(refl.klass.arel_table, refl.foreign_key)
    end

    def arlj_sql(assoc)
      arlj_arel(assoc).join_sources
    end

    def arlj_aggregate_arel(assoc, *args)
      options = args.extract_options!

      refl = reflect_on_association(assoc)
      refl_arel = refl.klass.arel_table

      join_name = "arlj_aggregate_#{refl.table_name}"

      columns = [refl_arel[refl.foreign_key]]
      args.each do |thunk|
        columns << parse_thunk(refl, assoc, refl_arel, thunk)
      end
      options.each do |thunk, name|
        columns << parse_thunk(refl, assoc, refl_arel, thunk, name)
      end

      subq_arel =
        refl_arel.project(columns).
                  from(refl_arel).
                  group(refl_arel[refl.foreign_key]).
                  as(join_name)

      arlj_left_join_arel(subq_arel, refl.foreign_key)
    end

    def arlj_aggregate_sql(assoc, *args)
      arlj_aggregate_arel(assoc, *args).join_sources
    end

    private

    THUNK_PATTERN = /^([a-zA-Z]*)\((.*)\)$/
    AGGREGATE_FUNCTIONS = {
      'sum'     => 'sum',
      'average' => 'average',
      'avg'     => 'average',
      'maximum' => 'maximum',
      'max'     => 'maximum',
      'minimum' => 'minimum',
      'min'     => 'minimum',
      'count'   => 'count',
    }.freeze
    def parse_thunk(refl, assoc, arel, thunk, name=nil)
      matchdata = THUNK_PATTERN.match(thunk)
      if matchdata.nil?
        raise "'#{thunk}' not parsable - must be of format 'func(column)'"
      end

      func = AGGREGATE_FUNCTIONS[matchdata[1].downcase]
      if func.nil?
        raise "'#{matchdata[1]}' not recognized - must be one of #{AGGREGATE_FUNCTIONS.keys}"
      end

      if matchdata[2] == '*'
        column = refl.active_record_primary_key
        name ||= "#{assoc}_#{func}"
      else
        column = matchdata[2]
        name ||= "#{assoc}_#{func}_#{column}"
      end
      arel[column].send(func).as(name)
    end

    def arlj_left_join_arel(arel, foreign_key)
      arel_table.join(arel, Arel::Nodes::OuterJoin).
                   on(arel[foreign_key].eq(arel_table[self.primary_key]))
    end
  end
end
