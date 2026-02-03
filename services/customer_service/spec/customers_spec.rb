require "rails_helper"

RSpec.describe "Customers API", type: :request do
  describe "GET /customers/:id" do
    it "returns customer data" do
      customer = Customer.create!(customer_name: "Jeison", address: "Bogotá", orders_count: 0)

      get "/customers/#{customer.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json["id"]).to eq(customer.id)
      expect(json["customer_name"]).to eq("Jeison")
      expect(json["address"]).to eq("Bogotá")
      expect(json["orders_count"]).to eq(0)
    end

    it "returns 404 when customer not found" do
      get "/customers/999999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /health" do
    it "returns ok" do
      get "/health"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({ "status" => "ok" })
    end
  end
end
