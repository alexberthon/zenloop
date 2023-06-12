require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  resources :profiles, only: [:show]
  resources :journeys do
    resources :steps, only: [:create]
  end
  resources :steps, only: [:destroy]
  get "lines/search", to: "lines#search"

  mount Sidekiq::Web => '/sidekiq'
end
