class CustomersController < ApplicationController
  def index
    customers = Customer.all

    render json: customers.map { |customer|
      {
        id: customer.id,
        customer_name: customer.customer_name,
        address: customer.address,
        orders_count: customer.orders_count
      }
    }
  end
  def show
    customer = Customer.find(params[:id])
    render json: {
      id: customer.id,
      customer_name: customer.customer_name,
      address: customer.address,
      orders_count: customer.orders_count
    }
  end
end
