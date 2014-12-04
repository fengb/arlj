require 'spec_helper'

require 'arlj'
require 'temping'

RSpec.describe Arlj do
  Temping.create :parent do
    with_columns do |t|
      t.string :name
    end

    extend Arlj

    has_many :children
  end

  Temping.create :child do
    with_columns do |t|
      t.integer :parent_id
      t.integer :col
    end
  end

  before(:all) do
    @parent = Parent.create(name: 'John')
    (1..10).each do |n|
      @parent.children.create(col: n)
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

    specify 'sum(col)' do
      children_sum_col = Parent.arlj_aggregate(:children, 'SUM(col)').pluck('children_sum_col').first
      assert{ children_sum_col == @parent.children.sum(:col) }
    end

    specify 'SUM(col) => name' do
      sum = Parent.arlj_aggregate(:children, 'sum(col)' => 'sum').pluck('sum').first
      assert{ sum == @parent.children.sum(:col) }
    end

    specify 'FAKE(col) raises error' do
      error = rescuing{ Parent.arlj_aggregate(:children, 'FAKE(col)') }
      assert{ error }
    end

    specify 'COUNT(*) => count, SUM(col) => sum' do
      array = Parent.arlj_aggregate(:children, 'count(*)' => 'count', 'sum(col)' => 'sum').pluck('count', 'sum').first
      assert{ array[0] == @parent.children.size }
      assert{ array[1] == @parent.children.sum(:col) }
    end
  end
end
