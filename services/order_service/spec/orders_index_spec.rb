require "rails_helper"

RSpec.describe "Orders API (index)", type: :request do
  it "requires customer_id" do
    get "/orders"
    expect(response).to have_http_status(:bad_request)
  end

  it "lists orders filtered by customer_id" do
    Order.create!(customer_id: 1, product_name: "Café", quantity: 2, price: 15000, status: "created")
    Order.create!(customer_id: 2, product_name: "Pan",  quantity: 1, price: 3000,  status: "created")

    get "/orders", params: { customer_id: 1 }

    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    expect(json.length).to eq(1)
    expect(json[0]["customer_id"]).to eq(1)
  end
end
