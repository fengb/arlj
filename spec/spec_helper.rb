require 'active_record'
require 'wrong/adapters/rspec'

RSpec.configure do |c|
  c.include Wrong
end

module ActiveRecord
  Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

  # shim for AR 3.1
  unless Base.respond_to?(:pluck)
    Base.delegate :pluck, to: :scoped

    class Relation
      def pluck(column_name)
        scope = self.select(column_name)
        self.connection.select_values(scope.to_sql).map! do |value|
          type_cast_using_column(value, column_for(column_name))
        end
      end
    end
  end
end
