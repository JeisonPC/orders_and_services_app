# frozen_string_literal: true

require "bunny"
require "json"

class OrderCreatedConsumer
  QUEUE = "customer_service.order_created".freeze
  EXCHANGE = "orders".freeze
  ROUTING_KEY = "order.created".freeze

  def start
    conn = Bunny.new(
      host: ENV.fetch("RABBITMQ_HOST", "rabbitmq"),
      port: ENV.fetch("RABBITMQ_PORT", "5672").to_i,
      username: ENV.fetch("RABBITMQ_USER", "guest"),
      password: ENV.fetch("RABBITMQ_PASSWORD", "guest")
    )

    conn.start
    ch = conn.create_channel
    ch.prefetch(10)

    exchange = ch.topic(EXCHANGE, durable: true)
    queue = ch.queue(QUEUE, durable: true)

    queue.bind(exchange, routing_key: ROUTING_KEY)

    puts "[CustomerService] Listening on #{QUEUE} (#{ROUTING_KEY})..."

    queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
      begin
        payload = JSON.parse(body)
        customer_id = payload.fetch("customer_id")
        order_id = payload.fetch("order_id")

        customer = Customer.find(customer_id)
        customer.increment!(:orders_count)

        puts "[CustomerService] Processed order_id=#{order_id} customer_id=#{customer_id}"

        ch.ack(delivery_info.delivery_tag)
      rescue StandardError => e
        warn "[CustomerService] Error: #{e.class} #{e.message}"
        # requeue=false para evitar bucles infinitos si el mensaje es malo
        ch.nack(delivery_info.delivery_tag, false, false)
      end
    end
  ensure
    conn&.close
  end
end
