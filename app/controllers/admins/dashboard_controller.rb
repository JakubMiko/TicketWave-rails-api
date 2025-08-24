module Admins
  class DashboardController < ApplicationController
    before_action :ensure_admin!

    def show
      events = Event.all.limit(5)
      users = User.where(role: "user").limit(5)
      statistics = {
        total_events: Event.count,
        total_users: User.where(role: "user").count,
        total_admins: User.where(role: "admin").count
      }

      render Devise::Admins::Dashboard::ShowComponent.new(
        events: events,
        users: users,
        statistics: statistics,
        current_admin: current_admin
      )
    end

    private

    def ensure_admin!
      unless admin_signed_in? && current_admin&.admin?
        redirect_to new_admin_session_path, alert: "Musisz być zalogowany jako administrator, aby uzyskać dostęp do tej strony."
      end
    end
  end
end
