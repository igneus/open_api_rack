require 'open_api_rack/configuration'

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
