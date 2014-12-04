require 'arlj'

module Arlj
  module LeftJoins
    include Arlj

    alias_method :left_joins, :arlj
    alias_method :left_joins_aggregate, :arlj_aggregate
  end
end
