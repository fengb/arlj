require 'spec_helper'

require 'arlj'

RSpec.describe Arlj, 'left_joins' do
  class LjParent < Parent
    extend Arlj
  end

  specify '#left_joins does arlj stuff' do
    counts = LjParent.left_joins(:children).
                    group('parents.id').
                    pluck('COUNT(children.id)')
    assert{ counts.sort == [0, 10] }
  end

  specify '#left_joins_aggregate does arlj_aggregate stuff' do
    children_count = LjParent.left_joins_aggregate(children: Child.select('COUNT(*) AS children_count')).
                              pluck('children_count').
                              first
    assert{ children_count == 10 }
  end
end
