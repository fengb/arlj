require 'memoist'

module Arlj
  extend Memoist

  def arlj(assoc)
    # Example snippet:
    #  LEFT JOIN [assoc]
    #         ON [assoc].source_id = source.id

    refl = reflect_on_association(assoc)
    sources = arlj_arel_sources(refl.klass.arel_table, refl.foreign_key)
    joins(sources)
  end

  # Example usage:
  #   arlj_aggregate(other, 'count(*)', 'sum(col)' => target_name)
  def arlj_aggregate(assoc, *args)
    # Example snippet:
    #  LEFT JOIN(SELECT source_id, [func]([column]) AS [target_name]
    #              FROM [assoc]
    #             GROUP BY [assoc].source_id) arlj_aggregate_[assoc]
    #         ON [assoc].source_id = source.id

    sources = arlj_aggregate_sources(assoc, *args)
    joins(sources)
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

  memoize \
  def arlj_aggregate_sources(assoc, *args)
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

    arlj_arel_sources(subq_arel, refl.foreign_key)
  end

  def arlj_arel_sources(arel, foreign_key)
    arel_join =
      arel_table.join(arel, Arel::Nodes::OuterJoin).
                   on(arel[foreign_key].eq(arel_table[self.primary_key]))
    arel_join.join_sources
  end
end
