Rails.application.routes.draw do
  post 'authenticate', to: 'authentication#authenticate'
  resources :notifications, only: [:index,:create,:show,:update,:destroy] do 
    resources :assignments, only: [:index,:create,:show,:update,:destroy], shallow: true
  end
  resources :clients, only: [:index]

  post 'client_notifications/:id', to: 'client_notifications#show'
  get  'client_notifications', to: 'client_notifications#index'

  get  'client_portfolios/:id/content', to: 'client_portfolios#content'
  get  'client_portfolios/:id/valuation', to: 'client_portfolios#valuation'
  get  'client_portfolios/:id/return', to: 'client_portfolios#return'
  get  'client_portfolios', to: 'client_portfolios#index'
end
