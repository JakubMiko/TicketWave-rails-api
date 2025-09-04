# frozen_string_literal: true

module Orders
  class FormComponent < BaseComponent
    attr_reader :event, :ticket_batch, :order

    def initialize(event:, ticket_batch:, order:)
      @event = event
      @ticket_batch = ticket_batch
      @order = order
    end
  end
end
