# frozen_string_literal: true

module Events
  class IndexComponent < BaseComponent
    attr_reader :events, :current_user

    def initialize(events:, current_user:)
      @events = events
      @current_user = current_user
    end
  end
end
