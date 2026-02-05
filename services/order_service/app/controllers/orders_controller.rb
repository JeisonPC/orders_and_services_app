class OrdersController < ApplicationController
  def index
    customer_id = params[:customer_id]
    return render json: { error: "customer_id is required" }, status: :bad_request if customer_id.blank?

    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 10).to_i
    per_page = [ [ per_page, 1 ].max, 100 ].min # Entre 1 y 100

    orders = Order.where(customer_id: customer_id)
                  .order(created_at: :desc)
                  .limit(per_page)
                  .offset((page - 1) * per_page)

    total = Order.where(customer_id: customer_id).count
    total_pages = (total.to_f / per_page).ceil

    render json: {
      data: orders,
      pagination: {
        current_page: page,
        per_page: per_page,
        total_items: total,
        total_pages: total_pages
      }
    }
  end

  def create
    client = CustomerServiceClient.new
    customer = client.fetch_customer(order_params[:customer_id])
  
    order = Order.new(order_params)

    if order.save
      OrderEventPublisher.new.publish_order_created(order_id: order.id, customer_id: order.customer_id)
      render json: order, status: :created
    else
      render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
    end
    rescue CustomerServiceClient::NotFound => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue CustomerServiceClient::Unavailable => e
      render json: { error: "Customer service unavailable", detail: e.message }, status: :service_unavailable
  end

  private

  def order_params
    params.require(:order).permit(:customer_id, :product_name, :quantity, :price, :status)
  end
end
