# frozen_string_literal: true

module Events
  class IndexComponent < BaseComponent
    attr_reader :events, :current_user, :view

    def initialize(events:, current_user:, view: nil)
      @events = events
      @current_user = current_user
      @view = view
    end
  end
end
