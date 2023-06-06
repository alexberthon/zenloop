Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  resources :profiles, only: [:show]
  resources :journeys
  resources :cities
  resources :stations
  resources :lines

end
