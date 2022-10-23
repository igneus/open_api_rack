# frozen_string_literal: true

require_relative "lib/open_api_rack/version"

Gem::Specification.new do |spec|
  spec.name = "open_api_rack"
  spec.version = OpenApiRack::VERSION
  spec.authors = ["Olga Leonteva"]
  spec.email = ["youzik@me.com"]

  spec.summary = "OpenAPI 3.0.0 documentation generator"
  spec.description = "Generate your own shiny OpenAPI 3.0.0 documentation from Rspec request specs"
  spec.homepage = ""
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = ""

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/chhlga/open_api_rack"
  spec.metadata["changelog_uri"] = ""

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
