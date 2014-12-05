require 'arlj/base'

module Arlj
  autoload :Version, 'arlj/version'
  include Arlj::Base

  alias_method :left_joins, :arlj
  alias_method :left_joins_aggregate, :arlj_aggregate
  alias_method :left_joins_arel, :arlj_arel
  alias_method :left_joins_aggregate_arel, :arlj_aggregate_arel

  def self.memoize!
    Arlj::Base.memoize!
  end
end
