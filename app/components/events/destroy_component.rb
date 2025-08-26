# frozen_string_literal: true

module Events
  class DestroyComponent < BaseComponent
    attr_reader :event

    def initialize(event:)
      @event = event
    end
  end
end
