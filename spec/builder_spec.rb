RSpec.describe OpenApiRack::Builder do
  subject { described_class.new(openapi_hash, headers) }
  let(:openapi_hash) { { "paths" => {} } }
  let(:headers) { [] }

  it "adds action description" do
    env = {
      "CONTENT_TYPE" => "application/json",
      "PATH_INFO" => "/api/v1/animals",
      "QUERY_STRING" => "element=water&region=Pacific",
      "REQUEST_METHOD" => "GET",
      "REQUEST_URI" => "http://www.example.org/api/v1/animals?element=water&region=Pacific",
      "SCRIPT_NAME" => "",
      "SERVER_NAME" => "example.org",
      "SERVER_PORT" => "9292",
      "SERVER_PROTOCOL" => "HTTP/1.1",
      "HTTP_HOST" => "www.example.org",
      "HTTP_ACCEPT_ENCODING" => "gzip, deflate, br",
      "HTTP_CONNECTION" => "keep-alive",
      "HTTP_ACCEPT" => "application/json, */*;q=0.5",
    }
    response = [
      200,
      { "content-type" => "application/json" },
      ["{}"],
    ]

    subject.add env, response

    expect(subject.open_api_hash["paths"])
      .to(eq({ "/api/v1/animals" => {
        "get" => {
          "parameters" => [
            { "example" => "water", "in" => "query", "name" => "element", "required" => false, "schema" => { "type" => "string" } },
            { "example" => "Pacific", "in" => "query", "name" => "region", "required" => false, "schema" => { "type" => "string" } },
          ],
          "responses" => {
            200 => {
              "content" => {
                "application/json" => {
                  "schema" => {
                    "properties" => {},
                    "type" => "object",
                  },
                },
              },
              "description" => "OK",
              "headers" => {},
            },
          },
        },
      } }))
  end
end
