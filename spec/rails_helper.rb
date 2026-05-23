# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

require_relative "spec_helper"
require_relative "dummy/config/application"
require "rails_llm"

Rails.application.initialize!
load File.expand_path("dummy/db/schema.rb", __dir__)

require "rspec/rails"

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
end
