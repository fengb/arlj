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
    #   arlj_aggregate(others: Other.select('SUM([col])' AS [alias])
    def arlj_aggregate(options)
      # Example snippet:
      #  LEFT JOIN(SELECT source_id, SUM([col]) AS [alias])
      #              FROM [assoc]
      #             GROUP BY [assoc].source_id) arlj_aggregate_[assoc]
      #         ON [assoc].source_id = source.id

      joins(arlj_aggregate_sql(options))
    end

    def arlj_arel(assoc)
      refl = reflect_on_association(assoc)
      arlj_left_join_arel(refl.klass.arel_table, refl.foreign_key)
    end

    def arlj_sql(assoc)
      arlj_arel(assoc).join_sources
    end

    def arlj_aggregate_arel(options)
      options.map do |assoc, relation|
        refl = reflect_on_association(assoc)
        foreign_key = refl.foreign_key
        subq_arel = relation.select(foreign_key).arel
        arlj_left_join_arel(subq_arel.as("arlj_aggregate_#{assoc}"), refl.foreign_key)
      end
    end

    def arlj_aggregate_sql(assoc, *args)
      arlj_aggregate_arel(assoc, *args).map(&:join_sources)
    end

    private

    def arlj_left_join_arel(arel, foreign_key)
      arel_table.join(arel, Arel::Nodes::OuterJoin).
                   on(arel[foreign_key].eq(arel_table[self.primary_key]))
    end
  end
end
