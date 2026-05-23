# frozen_string_literal: true

require_relative "lib/rails_llm/version"

Gem::Specification.new do |spec|
  spec.name = "rails-llm"
  spec.version = RailsLLM::VERSION
  spec.authors = ["0x1eef"]
  spec.email = ["0x1eef@hardenedbsd.org"]

  spec.description = <<~DESC.strip
  RailsLLM integrates the llm.rb runtime and its features into Rails.

  RailsLLM extends the builtin ActiveRecord support available to the llm.rb
  runtime with a Rails integration that includes generators for getting set up quickly,
  and an engine for a stream-capable chat interface that can be extended with your
  own tools.

  The llm.rb runtime runs on Ruby's standard library by default. loads optional pieces
  only when needed, and offers a single runtime for providers, agents, tools, skills, MCP,
  A2A (Agent2Agent), RAG (vector stores & embeddings), streaming, files, and persisted state.
  DESC
  spec.summary = spec.description

  spec.homepage = "https://github.com/llmrb/rails-llm"
  spec.license = "0BSD"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/releases"
  spec.metadata["documentation_uri"] = "https://0x1eef.github.io/x/llm.rb"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["lib/**/*", "app/**/*", "config/**/*"] +
    %w[README.md LICENSE Gemfile rails-llm.gemspec]
  spec.require_paths = ["lib"]

  spec.add_dependency "llm.rb", "~> 11.0"
  spec.add_dependency "redcarpet", "~> 3.6"
  spec.add_dependency "railties", ">= 7.0"
  spec.add_dependency "actioncable", ">= 7.0"
  spec.add_dependency "activerecord", ">= 7.0"

  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "sqlite3"
end
