require 'yaml'

module OpenApiRack
  class Middleware
    def initialize(app)
      @app = app

      @headers_list = OpenApiRack.configuration.headers_list
    end

    def call(env)
      app_call_result = @app.call(env)

      return app_call_result if skip?(env)

      if File.exist?("public/open-api.yaml")
        open_api_hash = YAML.load_file("public/open-api.yaml")
      else
        open_api_hash = {
          "openapi" => "3.0.0",
          "info" => {
            "title" => "client_area",
            "version" => "1.0.0"
          },
          "servers" => [
            {"url" => "http://localhost:3000"}
          ],
          "paths" => {}
        }
      end

      builder = Builder.new open_api_hash, @headers_list
      builder.add env, app_call_result

      File.open(path, 'w') do |f|
        f.write YAML.dump builder.open_api_hash
      end

      app_call_result
    end

    private

    def skip?(env)
      disable_by_default = OpenApiRack.configuration.disable_by_default
      skip_example = env["OA_SKIP_EXAMPLE"] == "true"
      include_example = env["OA_INCLUDE_EXAMPLE"] == "true"

      return false if include_example
      return true if disable_by_default
      return true if skip_example
    end
  end
end
