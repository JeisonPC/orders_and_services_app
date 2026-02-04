# frozen_string_literal: true

class ProcessedEvent < ApplicationRecord
  validates :order_id, presence: true, uniqueness: true
end
