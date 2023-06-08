Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  resources :profiles, only: [:show]
  resources :cities
  resources :stations

  get "lines/search", to: "lines#search"
  resources :lines, only: [:index, :show]

  resources :journeys do
    resources :steps, only: [:create]
  end
end
