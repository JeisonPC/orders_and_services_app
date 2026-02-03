class CustomersController < ApplicationController
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
