# frozen_string_literal: true

module Orders
  class ConfirmationComponent < BaseComponent
    attr_reader :order

    def initialize(order:)
      @order = order
    end
  end
end
