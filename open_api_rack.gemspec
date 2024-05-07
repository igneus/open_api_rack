# frozen_string_literal: true

require_relative "lib/open_api_rack/version"

Gem::Specification.new do |spec|
  spec.name = "open_api_rack"
  spec.version = OpenApiRack::VERSION
  spec.authors = ["Olga Leonteva"]
  spec.email = ["youzik@me.com"]

  spec.summary = "OpenAPI 3.0.0 documentation generator"
  spec.description = "Generate your own shiny OpenAPI 3.0.0 documentation from Rspec request specs"
  spec.homepage = "https://github.com/chhlga/open_api_rack"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/chhlga/open_api_rack"
  spec.metadata["changelog_uri"] = "https://github.com/chhlga/open_api_rack/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "deep_merge"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
