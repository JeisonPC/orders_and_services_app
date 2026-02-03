require "bunny"
require "json"

class OrderEventPublisher
  EXCHANGE = "orders".freeze
  ROUTING_KEY = "order.created".freeze

  def publish_order_created(order_id:, customer_id:)
    conn = Bunny.new(
      host: ENV.fetch("RABBITMQ_HOST", "rabbitmq"),
      port: ENV.fetch("RABBITMQ_PORT", "5672").to_i,
      username: ENV.fetch("RABBITMQ_USER", "guest"),
      password: ENV.fetch("RABBITMQ_PASSWORD", "guest")
    )

    conn.start
    ch = conn.create_channel

    exchange = ch.topic(EXCHANGE, durable: true)
    payload = {
      event: "order.created",
      order_id: order_id,
      customer_id: customer_id,
      occurred_at: Time.now.utc.iso8601
    }

    exchange.publish(payload.to_json, routing_key: ROUTING_KEY, persistent: true)
  ensure
    conn&.close
  end
end