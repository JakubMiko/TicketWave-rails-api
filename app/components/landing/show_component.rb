# frozen_string_literal: true

module Landing
  class ShowComponent < BaseComponent
    attr_reader :events

    def initialize(events:)
      @events = events
    end
  end
end
