# frozen_string_literal: true

module Events
  class TicketBatchesComponent < BaseComponent
    attr_reader :event, :current_user
    def initialize(event:, current_user:)
      @event = event
      @current_user = current_user
    end
  end
end
