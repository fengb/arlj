require 'spec_helper'

require 'arlj/left_joins'

RSpec.describe Arlj::LeftJoins do
  class LjParent < Parent
    extend Arlj::LeftJoins
  end

  specify '#left_joins does arlj stuff' do
    counts = LjParent.left_joins(:children).
                    group('parents.id').
                    pluck('COUNT(children.id)')
    assert{ counts.sort == [0, 10] }
  end

  specify '#left_joins_aggregate does arlj_aggregate stuff' do
    children_count = LjParent.left_joins_aggregate(:children, 'count(*)').
                              pluck('children_count').
                              first
    assert{ children_count == 10 }
  end
end
