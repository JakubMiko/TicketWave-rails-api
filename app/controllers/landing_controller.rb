class LandingController < ApplicationController
  def show
    events = Event.upcoming.limit(3)
    render Landing::ShowComponent.new(events: events)
  end
end
