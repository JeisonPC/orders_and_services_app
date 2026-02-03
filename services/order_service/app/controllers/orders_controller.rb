class OrdersController < ApplicationController
  def index
    customer_id = params[:customer_id]
    return render json: { error: "customer_id is required" }, status: :bad_request if customer_id.blank?

    orders = Order.where(customer_id: customer_id).order(created_at: :desc)
    render json: orders
  end

  def create
    order = Order.new(order_params)

    if order.save
      render json: order, status: :created
    else
      render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.require(:order).permit(:customer_id, :product_name, :quantity, :price, :status)
  end
end
