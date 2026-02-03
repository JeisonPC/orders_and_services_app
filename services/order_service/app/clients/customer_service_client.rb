class CustomerServiceClient
  class NotFound < StandardError; end
  class Unavailable < StandardError; end

  def initialize(base_url: ENV.fetch("CUSTOMER_SERVICE_URL", "http://customer_service:3002"))
    @conn = Faraday.new(url: base_url) do |f|
      f.request :json
      f.response :json, content_type: /\bjson$/
      f.adapter Faraday.default_adapter
      f.options.timeout = 2
      f.options.open_timeout = 2
    end
  end

  def fetch_customer(customer_id)
    res = @conn.get("/customers/#{customer_id}")

    case res.status
    when 200
      res.body
    when 404
      raise NotFound, "Customer #{customer_id} not found"
    else
      raise Unavailable, "Customer service error (status=#{res.status})"
    end
  rescue Faraday::Error => e
    raise Unavailable, e.message
  end
end
