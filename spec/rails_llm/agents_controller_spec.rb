# frozen_string_literal: true

require "rails_helper"
require "setup"

RSpec.describe RailsLLM::AgentsController, type: :controller do
  routes { RailsLLM::Engine.routes }
  let(:agent) { RailsLLM::Agent.create!(title: "Test Agent") }

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #show" do
    it "returns a successful response" do
      get :show, params: {id: agent.id}
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    it "creates a new agent" do
      expect {
        post :create, params: {agent: {title: "New"}}
      }.to change(RailsLLM::Agent, :count).by(1)
    end
  end
end
