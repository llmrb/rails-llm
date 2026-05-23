# frozen_string_literal: true

module RailsLLM
  class Agent < ::ActiveRecord::Base
    self.table_name = "rails_llm_agents"
    acts_as_agent provider: :set_provider, context: :set_context
    scope :ordered, -> { order(updated_at: :desc) }

    def title_or_default
      title.presence || "Agent ##{id}"
    end

    private

    def set_provider
      LLM.deepseek(key: "test-key")
    end

    def set_context
      {model: "deepseek-v4", store: false}
    end
  end
end
