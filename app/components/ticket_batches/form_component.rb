# frozen_string_literal: true

module TicketBatches
  class FormComponent < BaseComponent
    attr_reader :ticket_batch, :event

    def initialize(ticket_batch:, event:)
      @ticket_batch = ticket_batch
      @event = event
    end
  end
end
