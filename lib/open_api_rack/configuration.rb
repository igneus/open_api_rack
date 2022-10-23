module OpenApiRack
  class Configuration
    attr_accessor :headers_list

    def initialize(headers_list = nil)
      @headers_list = headers_list
    end
  end
end
