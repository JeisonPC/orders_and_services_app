# frozen_string_literal: true
require "swagger_helper"

RSpec.describe "Customers API", type: :request do
  path "/customers" do
    get "Lista todos los clientes" do
      tags "Customers"
      produces "application/json"

      response "200", "ok" do
        before do
          Customer.create!(
            customer_name: "Juan Perez",
            address: "Calle 123",
            orders_count: 5
          )
          Customer.create!(
            customer_name: "Maria Lopez",
            address: "Calle 456",
            orders_count: 3
          )
        end

        run_test!
      end
    end
  end

  path "/customers/{id}" do
    get "Obtiene información de un cliente" do
      tags "Customers"
      produces "application/json"
      parameter name: :id, in: :path, type: :integer, required: true

      response "200", "ok" do
        let(:id) { 1 }

        before do
          Customer.create!(
            id: 1,
            customer_name: "Juan Perez",
            address: "Calle 123",
            orders_count: 5
          )
        end

        run_test!
      end

      response "404", "customer not found" do
        let(:id) { 999 }

        run_test!
      end
    end
  end
end
