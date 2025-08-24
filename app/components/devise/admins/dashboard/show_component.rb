# frozen_string_literal: true

module Devise
  module Admins
    module Dashboard
      class ShowComponent < BaseComponent
        attr_reader :events, :users, :statistics, :current_admin

        def initialize(events:, users:, statistics:, current_admin:)
          @events = events
          @users = users
          @statistics = statistics
          @current_admin = current_admin
        end
      end
    end
  end
end
