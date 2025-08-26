# frozen_string_literal: true

module Events
  class Destroy < BaseService
    attr_reader :event

    def initialize(event_id:)
      super()
      @event = find_event(event_id)
    end

    def call
      return self if failure?

      destroy_event
      self
    end

    private

    def find_event(event_id)
      event = Event.find_by(id: event_id)
      errors << "Event not found." unless event
      event
    end

    def destroy_event
      unless event.destroy
        errors.concat(event.errors.full_messages)
      end
    end
  end
end
