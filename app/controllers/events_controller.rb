class EventsController < ApplicationController
  def index
    events = Event.upcoming

    render Events::IndexComponent.new(events: events, current_user: current_user, view: params[:view]), status: :ok
  end

  def show
    event = Event.includes(:ticket_batches).find(params[:id])

    render Events::ShowComponent.new(event: event, current_user: current_user), status: :ok
  end

  def new
    event = Event.new

    render Events::FormComponent.new(event: event), status: :ok
  end

  def create
    service = Events::Create.call(params: event_params)

    if service.success?
      redirect_to events_path, notice: "Wydarzenie zostało dodane."
    else
      render :new, locals: { event: service.event }, status: :unprocessable_entity
    end
  end

  def edit
    event = Event.find(params[:id])

    if event.past?
      redirect_to events_path, alert: t("events.edit.past_event_error")
    else
      render Events::FormComponent.new(
        event: event,
        url: event_path(event),
        method: :patch
      ), status: :ok
    end
  end

  def update
    event = Event.find_by(id: params[:id])

    if event
      contract = EventContract.new
      result = contract.call(event_params.to_h)

      if result.success?
        if event.update(event_params)
          redirect_to events_path, notice: t("events.update.success")
        else
          render Events::FormComponent.new(
            event: event,
            url: event_path(event),
            method: :patch
          ), status: :unprocessable_entity
        end
      else
        result.errors.to_h.each do |key, messages|
          Array(messages).each do |message|
            if key.present?
              event.errors.add(key, message)
            else
              event.errors.add(:base, message)
            end
          end
        end

        render Events::FormComponent.new(
          event: event,
          url: event_path(event),
          method: :patch
        ), status: :unprocessable_entity
      end
    else
      render :not_found, status: :not_found
    end
  end

  def destroy
    event = Event.find(params[:id])
    event.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("event_#{event.id}") }
      format.html { redirect_to events_path, notice: t("events.destroy.success") }
    end
  end

  private

  def event_params
    params.require(:event).permit(:name, :description, :place, :date, :category, :image)
  end
end
