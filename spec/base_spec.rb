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
    specify 'Child.select("COUNT(*)")' do
      children_count = Parent.arlj_aggregate(Child.select('COUNT(*) AS children_count')).
                              pluck('children_count').
                              first
      assert{ children_count == @parent.children.size }
    end

    specify 'Child.select("SUM(age)")' do
      sum_age = Parent.arlj_aggregate(Child.select('SUM(age) AS sum_age')).
                       pluck('sum_age').
                       first
      assert{ sum_age == @parent.children.sum(:age) }
    end

    specify 'Child.where("age > 4").select("COUNT(*)")' do
      count = Parent.arlj_aggregate(Child.where('age > 4').select('COUNT(*) as children_count')).
                     pluck('children_count').
                     first
      assert{ count == @parent.children.where('age > 4').count }
    end

    specify 'children: Child.select("COUNT(*)")' do
      count = Parent.arlj_aggregate(children: Child.select('COUNT(*) as children_count')).
                     pluck('children_count').
                     first
      assert{ count == @parent.children.count }
    end
  end
end
