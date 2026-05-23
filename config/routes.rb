# frozen_string_literal: true

RailsLLM::Engine.routes.draw do
  resources :agents, only: %i[index show create] do
    member do
      post :ask
    end
  end

  root to: "agents#index"
end
