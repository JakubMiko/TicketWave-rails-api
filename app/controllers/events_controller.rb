class EventsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy ]

  def index
    # CACHE EXAMPLE 1: Cache expensive database query
    # Cache key: "events/upcoming/grid" lub "events/upcoming/list"
    # Expires after 5 minutes OR when any event is updated
    cache_key = "events/upcoming/#{params[:view] || 'grid'}"

    events = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      # This block executes ONLY if cache is empty/expired
      Rails.logger.info "🔴 CACHE MISS: Loading events from database"
      Event.upcoming.to_a  # .to_a executes query and caches result array
    end

    Rails.logger.info "✅ CACHE HIT: Loaded #{events.count} events from memcached"

    render Events::IndexComponent.new(events: events, current_user: current_user, view: params[:view]), status: :ok
  end

  def show
    # CACHE EXAMPLE 2: Cache single event with associations
    # Cache key automatically includes event.updated_at timestamp
    # When event updates, cache key changes → auto-invalidation!
    event = Event.includes(:ticket_batches).find(params[:id])

    cached_event = Rails.cache.fetch([ "event", event ], expires_in: 1.hour) do
      Rails.logger.info "🔴 CACHE MISS: Loading event #{event.id} from database"
      event
    end

    render Events::ShowComponent.new(event: cached_event, current_user: current_user), status: :ok
  end

  def new
    event = Event.new
    render Events::FormComponent.new(
      event: event,
      url: events_path,
      method: :post
    ), status: :ok
  end

  def create
    service = Events::CreateService.call(params: event_params)
    if service.success?
      # CACHE INVALIDATION: Clear cache after creating new event
      clear_events_cache
      redirect_to events_path, notice: t("events.create.success")
    else
      flash.now[:alert] = service.errors.join("\n")
      render Events::FormComponent.new(
        event: service.event,
        url: events_path,
        method: :post
      ), status: :unprocessable_content
    end
  end

  def edit
    event = Event.find(params[:id])
    if event.past?
      redirect_to events_path, alert: t("events.edit.past_event_error") and return
    end

    render Events::FormComponent.new(
      event: event,
      url: event_path(event),
      method: :patch
    ), status: :ok
  end

  def update
    event = Event.find_by(id: params[:id])
    return render :not_found, status: :not_found unless event

    service = Events::UpdateService.call(event: event, params: event_params)
    if service.success?
      # CACHE INVALIDATION: Clear cache after updating event
      clear_events_cache
      redirect_to events_path, notice: t("events.update.success")
    else
      flash.now[:alert] = service.errors.join("\n")
      render Events::FormComponent.new(
        event: service.event,
        url: event_path(event),
        method: :patch
      ), status: :unprocessable_content
    end
  end

  def destroy
    event = Event.find(params[:id])
    event.destroy

    # CACHE INVALIDATION: Clear cache after deleting event
    clear_events_cache

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("event_#{event.id}") }
      format.html { redirect_to events_path, notice: t("events.destroy.success") }
    end
  end

  private

  def event_params
    params.require(:event).permit(:name, :description, :place, :date, :category, :image)
  end

  # CACHE HELPER: Clear all events-related cache
  def clear_events_cache
    Rails.logger.info "🗑️ Clearing events cache..."
    Rails.cache.delete_matched("events/upcoming/*")  # Clear all view variants
    Rails.logger.info "✅ Events cache cleared"
  end
end
