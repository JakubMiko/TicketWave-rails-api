# frozen_string_literal: true

module Orders
  class FormComponent < BaseComponent
    attr_reader :event, :ticket_batch, :order, :current_user

    def initialize(event:, ticket_batch:, order:, current_user:)
      @event = event
      @ticket_batch = ticket_batch
      @order = order
      @current_user = current_user
    end
  end
end
