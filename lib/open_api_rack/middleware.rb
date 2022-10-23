module OpenApiRack
  class Middleware
    def initialize(app)
      @app = app

      @headers_list = OpenApiRack.configuration.headers_list
    end

    def call(env)
      app_call_result = @app.call(env)

      return app_call_result if env["OA_SKIP_EXAMPLE"] == "true"

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

      open_api_hash["paths"].merge!(
        env["PATH_INFO"] => {
          env["REQUEST_METHOD"].downcase => {
            "parameters" => Rack::Request.new(env).params.map do |k, v|
              {
                "name" => k,
                "in" => "query",
                "schema" => {
                  "type" => "string"
                },
                "required" => false,
                "example" => v
              }
            end.concat(
              @headers_list.map do |k|
                {
                  "name" => k,
                  "in" => "header",
                  "schema" => {
                    "type" => "string"
                  },
                  "required" => false,
                  "example" => env["HTTP_#{k.to_s.upcase}"]
                }
              end
            ),
            "responses" => {
              app_call_result[0] => {
                "description" => "OK",
                "content" => {
                  "application/json" => {
                    "schema" => {
                      "type" => "object",
                      "properties" => parse_json(response_body(app_call_result))
                    }
                  }
                },
                "headers" => response_headers(app_call_result)
              }
            }
          }.merge(parsed_request_body(env))
        }
      )

      File.open('public/open-api.yaml', 'w') do |f|
        f.write(open_api_hash.to_yaml)
      end

      app_call_result
    end

    private

    def request_body(env)
      Rack::Request.new(env).params
    end

    def parsed_request_body(env)
      return {} unless env["REQUEST_METHOD"] == "POST" ||
        env["REQUEST_METHOD"] == "PUT" ||
          env["REQUEST_METHOD"] == "PATCH"
      {
        "requestBody" => {
          "content" => {
            "application/json" => {
              "schema" => {
                "type" => "object",
                "properties" => parse_json(request_body(env))
              }
            }
          }
        }
      }
    end

    def response_body(app_call_result)
      JSON.parse(app_call_result[2].first)
    end

    def parse_json(json, result = {})
      return result unless json.respond_to?(:each)
      json.each do |k, v|
        result[k], node = parse_node(v)
        if result[k]["type"] == "object"
          parse_json(node, result[k]["properties"])
        elsif result[k]["type"] == "array"
          parse_json(node, result[k]["items"]["properties"])
        end
      end
      result
    end

    def parse_node(node)
      if node.is_a?(Array)
        return {"type" => "array", "items" => { "properties" => {} } }, node.first
      elsif node.is_a?(Hash)
        return {"type" => "object", "properties" => {} }, node
      else
        return {"type" => "string" }, node
      end
    end

    def response_headers(app_call_result)
      result = {}
      app_call_result[1].keys.select { |k| @headers_list.include?(k) }.each do |k|
        result[k] = {
          "schema" => {
            "type" => "string"
          },
          "description" => "Header #{k}"
        }
      end
      result
    end
  end
end
