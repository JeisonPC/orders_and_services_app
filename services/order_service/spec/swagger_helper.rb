# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  config.swagger_root = Rails.root.join("swagger").to_s

  config.swagger_docs = {
    "v1/swagger.json" => {
      openapi: "3.0.1",
      info: {
        title: "Order Service API",
        version: "v1"
      },
      paths: {},
      servers: [
        {
          url: "http://localhost:3001",
          variables: {}
        }
      ]
    }
  }

  config.swagger_format = :json
end
