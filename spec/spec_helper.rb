require 'active_record'
require 'wrong/adapters/rspec'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

RSpec.configure do |c|
  c.include Wrong
end
