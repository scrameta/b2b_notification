# frozen_string_literal: true

Rails.application.routes.draw do
  post 'authenticate', to: 'authentication#authenticate'
  resources :notifications, only: %i[index create show update destroy] do
    resources :assignments, only: %i[index create show update destroy], shallow: true
  end
  resources :clients, only: [:index]

  resources :client_notifications, only: %i[index show]
  resources :client_portfolios, only: [:index]
  # custom actions:
  get  'client_portfolios/:id/content', to: 'client_portfolios#content'
  get  'client_portfolios/:id/valuation', to: 'client_portfolios#valuation'
  get  'client_portfolios/:id/return', to: 'client_portfolios#return'
end
