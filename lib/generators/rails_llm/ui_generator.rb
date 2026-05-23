# frozen_string_literal: true

require "rails/generators"

module RailsLLM
  ##
  # Model generator for rails-llm.
  # Creates an Agent model with acts_as_agent.
  # @usage rails generate rails_llm:model
  class ModelGenerator < ::Rails::Generators::Base
    namespace "rails_llm:model"
    source_root File.expand_path("templates", __dir__)
    desc "Generate an Agent model with acts_as_agent."

    def create_agent_model
      template "agent_model.rb.tt", "app/models/rails_llm/agent.rb"
    end

    def show_instructions
      say ""
      say "Done! Next steps:", :green
      say "  1. Run `rails db:migrate`", :bold
      say "  2. Visit http://localhost:3000/ai/agents", :bold
      say "  3. Set DEEPSEEK_API_KEY in your environment", :bold
      say ""
    end
  end
end
