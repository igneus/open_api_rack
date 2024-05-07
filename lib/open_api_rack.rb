require 'open_api_rack/configuration'
require 'open_api_rack/builder'
require 'open_api_rack/middleware'

module OpenApiRack
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @@configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
