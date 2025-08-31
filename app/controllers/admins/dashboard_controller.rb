module Admins
  class DashboardController < ApplicationController
    before_action :ensure_admin!

    def show
      events = Event.all.limit(5)
      users = User.where(admin: false).limit(5)
      statistics = {
        total_events: Event.count,
        total_users: User.where(admin: false).count,
        total_admins: User.where(admin: true).count
      }

      render Admins::ShowComponent.new(
        events: events,
        users: users,
        statistics: statistics
      )
    end

    private

    def ensure_admin!
      unless current_user.admin?
        redirect_to new_admin_session_path, alert: "Musisz być zalogowany jako administrator, aby uzyskać dostęp do tej strony."
      end
    end
  end
end
