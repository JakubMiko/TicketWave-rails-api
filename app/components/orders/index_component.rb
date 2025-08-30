# frozen_string_literal: true

module Orders
  class IndexComponent < BaseComponent
    attr_reader :orders

    def initialize(orders:)
      @orders = orders.order(created_at: :desc)
    end
  end
end
