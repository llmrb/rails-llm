# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module RailsLLM
  ##
  # Install generator for rails-llm.rb.
  # Creates the Agent model, migration, initializer, and engine route.
  # @usage rails generate rails_llm:install
  class InstallGenerator < ::Rails::Generators::Base
    include ::ActiveRecord::Generators::Migration
    namespace "rails_llm:install"
    source_root File.expand_path("templates", __dir__)
    desc "Install rails-llm.rb — creates the model, migration, initializer, and engine route."

    def create_agent_model
      template "agent_model.rb.tt", "app/models/rails_llm/agent.rb"
    end

    def create_knowledge_tool
      template "knowledge_tool.rb.tt", "app/tools/rails_llm/knowledge_tool.rb"
    end

    def create_install_migration
      migration_template "migration.rb.tt", "db/migrate/create_rails_llm_agents.rb"
    end

    def create_initializer
      template "initializer.rb.tt", "config/initializers/rails_llm.rb"
    end

    def mount_engine
      route %(mount RailsLLM::Engine => "/ai")
    end

    private

    def migration_version
      "[#{ActiveRecord::Migration.current_version}]"
    end
  end
end
