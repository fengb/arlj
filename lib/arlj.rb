require 'arlj/base'

module Arlj
  autoload :Version, 'arlj/version'
  include Arlj::Base

  alias_method :left_joins, :arlj
  alias_method :left_joins_aggregate, :arlj_aggregate

  def self.memoize!
    Arlj::Base.memoize!
  end
end
