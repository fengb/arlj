module Arlj
  module Base
    def self.memoize!
      $stderr.puts 'Arlj::Base.memoize! is deprecated and no longer works'
    end

    def arlj(assoc)
      # Example snippet:
      #  LEFT JOIN [assoc]
      #         ON [assoc].source_id = source.id

      joins(arlj_sql(assoc))
    end

    # Example usage:
    #   arlj_aggregate(Other.select('SUM([col])' AS [alias])
    #   arlj_aggregate(others: Other.select('SUM([col])' AS [alias])
    def arlj_aggregate(*args)
      # Example snippet:
      #  LEFT JOIN(SELECT source_id, SUM([col]) AS [alias])
      #              FROM [assoc]
      #             GROUP BY [assoc].source_id) arlj_aggregate_[assoc]
      #         ON [assoc].source_id = source.id

      joins(arlj_aggregate_sql(*args))
    end

    def arlj_arel(assoc)
      refl = reflect_on_association(assoc)
      arlj_left_join_arel(refl.klass.arel_table, refl.foreign_key)
    end

    def arlj_sql(assoc)
      arlj_arel(assoc).join_sources
    end

    def arlj_aggregate_arel(*args)
      options = args.extract_options!

      [].tap do |arels|
        args.each do |relation|
          refl = reflect_on_relation(relation)
          foreign_key = refl.foreign_key
          subq_arel = relation.select(foreign_key).arel
          arels << arlj_left_join_arel(subq_arel.as("arlj_aggregate_#{refl.name}"), refl.foreign_key)
        end

        options.each do |assoc, relation|
          refl = reflect_on_association(assoc)
          foreign_key = refl.foreign_key
          subq_arel = relation.select(foreign_key).arel
          arels << arlj_left_join_arel(subq_arel.as("arlj_aggregate_#{assoc}"), refl.foreign_key)
        end
      end
    end

    def arlj_aggregate_sql(*args)
      arlj_aggregate_arel(*args).map(&:join_sources)
    end

    private

    def reflect_on_relation(relation)
      matching = reflect_on_all_associations.select{ |assoc| assoc.klass == relation.klass }
      if matching.size == 1
        return matching.first
      elsif matching.size > 1
        raise 'Arlj: did not find unique match'
      else
        raise 'Arlj: did not find match'
      end
    end

    def arlj_left_join_arel(arel, foreign_key)
      arel_table.join(arel, Arel::Nodes::OuterJoin).
                   on(arel[foreign_key].eq(arel_table[self.primary_key]))
    end
  end
end
