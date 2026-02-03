Rails.application.routes.draw do
  get "/health", to: "health#show"
  get "/customers/:id", to: "customers#show"
end
