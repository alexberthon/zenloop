require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  get '/journey/:id/like', to: 'journeys#like', as: 'like'

  resources :profiles, only: [:show]
  resources :lines, only: [:index, :show]
  resources :journeys do
    resources :steps, only: [:create]
  end
  resources :steps, only: [:destroy]

  mount Sidekiq::Web => '/sidekiq'
end
