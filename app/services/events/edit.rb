# frozen_string_literal: true

module Events
  class Edit < BaseService
    attr_reader :event_id, :event

    def initialize(event_id:)
      @event_id = event_id
    end

    def call
      @event = Event.find_by(id: event_id)

      return failure([ "Event not found" ]) unless event

      success
    end
  end
end
