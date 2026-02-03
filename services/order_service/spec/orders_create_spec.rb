require "rails_helper"

RSpec.describe "Orders API (create)", type: :request do
  let(:payload) do
    {
      order: {
        customer_id: 1,
        product_name: "Azúcar",
        quantity: 1,
        price: 5000,
        status: "created"
      }
    }
  end

  it "creates an order when customer exists" do
    # mock del client
    client_double = instance_double(CustomerServiceClient)
    allow(CustomerServiceClient).to receive(:new).and_return(client_double)
    allow(client_double).to receive(:fetch_customer).with(1).and_return({
      "id" => 1,
      "customer_name" => "Jeison",
      "address" => "Bogotá",
      "orders_count" => 0
    })

    # mock del publisher de eventos
    publisher_double = instance_double(OrderEventPublisher)
    allow(OrderEventPublisher).to receive(:new).and_return(publisher_double)
    allow(publisher_double).to receive(:publish_order_created)

    expect {
      post "/orders", params: payload, as: :json
    }.to change(Order, :count).by(1)

    expect(response).to have_http_status(:created)

    order = Order.last
    expect(publisher_double).to have_received(:publish_order_created).with(order_id: order.id, customer_id: 1)
  end

  it "returns 422 when customer does not exist" do
    client_double = instance_double(CustomerServiceClient)
    allow(CustomerServiceClient).to receive(:new).and_return(client_double)
    allow(client_double).to receive(:fetch_customer).and_raise(CustomerServiceClient::NotFound.new("Customer 9999 not found"))

    expect {
      post "/orders", params: {
        order: payload[:order].merge(customer_id: 9999)
      }, as: :json
    }.not_to change(Order, :count)

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "returns 503 when customer service is unavailable" do
    client_double = instance_double(CustomerServiceClient)
    allow(CustomerServiceClient).to receive(:new).and_return(client_double)
    allow(client_double).to receive(:fetch_customer).and_raise(CustomerServiceClient::Unavailable.new("timeout"))

    post "/orders", params: payload, as: :json

    expect(response).to have_http_status(:service_unavailable)
  end
end
