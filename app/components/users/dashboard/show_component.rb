# frozen_string_literal: true

module Users
  module Dashboard
    class ShowComponent < ViewComponent::Base
      attr_reader :events, :statistics, :current_user

      def initialize(events:, statistics:, current_user:)
        @events = events
        @statistics = statistics
        @current_user = current_user
      end
    end
  end
end
