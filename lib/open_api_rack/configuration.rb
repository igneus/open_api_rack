module OpenApiRack
  class Configuration
    attr_accessor :headers_list, :disable_by_default

    def initialize(headers_list = nil, disable_by_default = false)
      @headers_list = headers_list
      @disable_by_default = disable_by_default
    end
  end
end
