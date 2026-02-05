# frozen_string_literal: true
require "swagger_helper"

RSpec.describe "Orders API", type: :request do
  path "/orders" do
    get "Lista pedidos por customer_id" do
      tags "Orders"
      produces "application/json"
      parameter name: :customer_id, in: :query, type: :integer, required: true
      parameter name: :page, in: :query, type: :integer, required: false, description: "Número de página (default: 1)"
      parameter name: :per_page, in: :query, type: :integer, required: false, description: "Cantidad por página (default: 10, max: 100)"

      response "200", "ok" do
        let(:customer_id) { 1 }

        before do
          Order.create!(
            customer_id: 1,
            product_name: "Cafe",
            quantity: 1,
            price: 5000,
            status: "created"
          )
        end

        run_test!
      end
    end

    post "Crea un pedido" do
      tags "Orders"
      consumes "application/json"
      produces "application/json"

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            required: %w[customer_id product_name quantity price status],
            properties: {
              customer_id: { type: :integer },
              product_name: { type: :string },
              quantity: { type: :integer },
              price: { type: :number },
              status: { type: :string }
            }
          }
        }
      }

      response "201", "creado" do
        let(:payload) do
          {
            order: {
              customer_id: 1,
              product_name: "Azucar",
              quantity: 1,
              price: 5000,
              status: "created"
            }
          }
        end

        before do
          client = instance_double(CustomerServiceClient)
          allow(CustomerServiceClient).to receive(:new).and_return(client)
          allow(client).to receive(:fetch_customer).and_return({ "id" => 1 })

          publisher = instance_double(OrderEventPublisher)
          allow(OrderEventPublisher).to receive(:new).and_return(publisher)
          allow(publisher).to receive(:publish_order_created)
        end

        run_test!
      end
    end
  end
end
