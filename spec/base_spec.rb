require 'spec_helper'

require 'arlj'
require 'temping'

RSpec.describe Arlj::Base do
  Temping.create :parent do
    with_columns do |t|
      t.string :name
    end

    extend Arlj::Base

    has_many :children
  end

  Temping.create :child do
    with_columns do |t|
      t.integer :parent_id
      t.integer :age
    end
  end

  before(:all) do
    @parent = Parent.create(name: 'John')
    (1..10).each do |n|
      @parent.children.create(age: n)
    end

    @parent_no_child = Parent.create(name: 'Jane')
  end

  describe '#arlj' do
    it 'joins the other table' do
      counts = Parent.arlj(:children).
                      group('parents.id').
                      pluck('COUNT(children.id)')
      assert{ counts.sort == [0, 10] }
    end
  end

  describe '#arlj_aggregate' do
    specify 'COUNT(*)' do
      children_count = Parent.arlj_aggregate(:children, 'count(*)').pluck('children_count').first
      assert{ children_count == @parent.children.size }
    end

    specify 'sum(age)' do
      children_sum_age = Parent.arlj_aggregate(:children, 'SUM(age)').pluck('children_sum_age').first
      assert{ children_sum_age == @parent.children.sum(:age) }
    end

    specify 'SUM(age) => name' do
      sum = Parent.arlj_aggregate(:children, 'sum(age)' => 'sum').pluck('sum').first
      assert{ sum == @parent.children.sum(:age) }
    end

    specify 'FAKE(age) raises error' do
      error = rescuing{ Parent.arlj_aggregate(:children, 'FAKE(age)') }
      assert{ error }
    end

    specify 'COUNT(*) => count, SUM(age) => sum' do
      array = Parent.arlj_aggregate(:children, 'count(*)' => 'count', 'sum(age)' => 'sum').pluck('count', 'sum').first
      assert{ array[0] == @parent.children.size }
      assert{ array[1] == @parent.children.sum(:age) }
    end
  end
end
