Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  resources :orders, only: [:index, :create]
  get "/health", to: "health#show"
end
