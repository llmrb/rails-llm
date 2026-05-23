# frozen_string_literal: true

Rails.application.routes.draw do
  mount RailsLLM::Engine => "/ai"
end
