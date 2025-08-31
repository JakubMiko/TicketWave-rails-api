# frozen_string_literal: true

module Admins
  class ShowComponent < BaseComponent
    attr_reader :events, :users, :statistics

    def initialize(events:, users:, statistics:)
      @events = events
      @users = users
      @statistics = statistics
    end
  end
end
