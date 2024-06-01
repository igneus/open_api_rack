require 'json'
require 'deep_merge'

module OpenApiRack
  class Builder
    def initialize(open_api_hash, headers_list)
      @open_api_hash = open_api_hash
      @headers_list = headers_list
    end

    attr_reader :open_api_hash

    # accepts a Rack environment and corresponding Rack response,
    # updates #open_api_hash accordingly
    def add(env, response)
      return unless response[1]['Content-Type']&.include?('json')

      open_api_hash["paths"].deep_merge!(
        env["PATH_INFO"] => {
          env["REQUEST_METHOD"].downcase => {
            "parameters" => Rack::Request.new(env).GET.map do |k, v|
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
              response[0] => {
                "description" => "OK",
                "content" => {
                  "application/json" => {
                    "schema" => {
                      "type" => "object",
                      "properties" => parse_json(response_body(response))
                    }
                  }
                },
                "headers" => response_headers(response)
              }
            }
          }.merge(parsed_request_body(env))
        }
      )
    end

    private

    def request_body(env)
      JSON.parse Rack::Request.new(env).body.read
    end

    def parsed_request_body(env)
      return {} unless env["REQUEST_METHOD"] == "POST" ||
        env["REQUEST_METHOD"] == "PUT" ||
        env["REQUEST_METHOD"] == "PATCH"

      properties =
        begin
          parse_json(request_body(env))
        rescue JSON::ParserError => e
          STDERR.puts "Failed to parse request body: #{e}"
          STDERR.puts "Environment:\n" + env.inspect

          # produce note also in the resulting OpenAPI document
          {'#COMMENT' => 'FAILED TO PARSE REQUEST BODY'}
        end

      {
        "requestBody" => {
          "content" => {
            "application/json" => {
              "schema" => {
                "type" => "object",
                "properties" => properties
              }
            }
          }
        }
      }
    end

    def response_body(app_call_result)
      JSON.parse(app_call_result[2].each.first)
    rescue JSON::ParserError => e
      STDERR.puts "Failed to parse response body: #{e}"
      STDERR.puts "Response:\n" + app_call_result.inspect

      # produce note also in the resulting OpenAPI document
      {'#COMMENT' => 'FAILED TO PARSE RESPONSE BODY'}
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
