Rails.application.routes.draw do
  resources :orders, only: [:index, :create]
  get "/health", to: "health#show"
end
