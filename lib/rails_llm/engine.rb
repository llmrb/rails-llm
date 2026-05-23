# frozen_string_literal: true

module RailsLLM
  ##
  # {RailsLLM::Engine} is the Rails engine that mounts the chat UI
  # and provides the generator infrastructure.
  class Engine < ::Rails::Engine
    isolate_namespace RailsLLM

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.assets false
      g.helper false
    end

    initializer "rails_llm.assets" do |app|
      next unless app.config.respond_to?(:assets)
      app.config.assets.precompile += %w[rails_llm/application.css rails_llm/application.js]
    end

    initializer "rails_llm.active_record" do
      ActiveSupport.on_load(:active_record) do
        require "llm/active_record"
      end
    end
  end
end
