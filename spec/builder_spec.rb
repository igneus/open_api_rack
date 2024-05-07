RSpec.describe OpenApiRack::Builder do
  subject { described_class.new(openapi_hash, headers) }
  let(:openapi_hash) { { "paths" => {} } }
  let(:headers) { [] }

  let(:default_env) do
    {
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
  end

  let(:default_response) do
    [
      200,
      { "content-type" => "application/json" },
      ["{}"],
    ]
  end

  it "adds action description" do
    subject.add default_env, default_response

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

  it "collects multiple paths" do
    paths = %w(/path1 /path2 /path3)
    paths.each do |i|
      subject.add default_env.merge("PATH_INFO" => i), default_response
    end

    expect(subject.open_api_hash["paths"].keys).to eq paths
  end

  it "collects multiple methods on the same path" do
    methods = %w(GET POST)
    methods.each do |i|
      subject.add default_env.merge("REQUEST_METHOD" => i), default_response
    end

    expect(subject.open_api_hash["paths"]["/api/v1/animals"].keys).to eq methods.collect(&:downcase)
  end

  it "collects parameters over multiple requests" do
    queries = %w(a=1 b=2&c=3 d=4)
    queries.each do |i|
      subject.add default_env.merge("QUERY_STRING" => i), default_response
    end

    expect(subject.open_api_hash["paths"]["/api/v1/animals"]["get"]["parameters"].collect { |i| i["name"] }).to eq %w(a b c d)
  end
end
