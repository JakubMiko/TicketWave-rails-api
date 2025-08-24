module Users
  class DashboardController < ApplicationController
    before_action :ensure_user!

    def show
      events = Event.joins(:tickets).where(tickets: { user_id: current_user.id }).distinct.limit(5)

      statistics = {
        total_events: Event.joins(:tickets).where(tickets: { user_id: current_user.id }).distinct.count,
        total_tickets: Ticket.where(user_id: current_user.id).count
      }

      render Users::Dashboard::ShowComponent.new(
        events: events,
        statistics: statistics,
        current_user: current_user
      )
    end

    private

    def ensure_user!
      unless user_signed_in?
        redirect_to new_user_session_path, alert: "Musisz być zalogowany jako użytkownik, aby uzyskać dostęp do tej strony."
      end
    end
  end
end
