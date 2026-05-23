# frozen_string_literal: true

module RailsLLM
  class AgentsController < ::ApplicationController
    include ActionController::Live

    layout "rails_llm/application"
    before_action :set_agents
    before_action :set_agent, only: %i[show ask]

    def index
      @agent = Agent.new
    end

    def show
      @messages = messages
    end

    def create
      @agent = Agent.create!(create_params)
      respond_to do |format|
        format.html { redirect_to agent_path(@agent) }
        format.json { render json: {location: agent_path(@agent)} }
      end
    end

    def ask
      prompt = params[:prompt]
      return head(:unprocessable_entity) if prompt.blank?
      response.headers["Content-Type"] = "application/x-ndjson; charset=utf-8"
      response.headers["Cache-Control"] = "no-cache"
      response.headers["X-Accel-Buffering"] = "no"
      stream = Stream.new(response.stream)
      @agent.ask(prompt, stream:)
      stream.finish
    ensure
      response.stream.close
    end

    private

    def set_agent
      @agent = Agent.find(params[:id])
    end

    def set_agents
      @agents = Agent.ordered
    end

    def create_params
      allowed = {}
      prompt = params[:prompt].to_s.strip
      allowed.merge!(title: prompt.tr("\n", " ")[0, 80])
    end

    def messages
      @agent
        .messages
        .select { _1.user? || _1.assistant? }
        .reject { _1.tool_call? || _1.tool_return? }
    end
  end
end
