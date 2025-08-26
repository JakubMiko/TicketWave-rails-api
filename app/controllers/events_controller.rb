class EventsController < ApplicationController
  def index
    service = Events::Index.call

    if service.success?
      render Events::IndexComponent.new(events: service.events, current_user: current_user), status: :ok
    else
      flash.now[:alert] = service.errors.join(", ")
      render Events::IndexComponent.new(events: service.events, current_user: current_user), status: :unprocessable_entity
    end
  end

  def show
    event = Event.includes(:ticket_batches).find(params[:id])

    if event
      render Events::ShowComponent.new(event: event, current_user: current_user), status: :ok
    else
      render :not_found, status: :not_found
    end
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
    event = Event.find_by(id: params[:id])

    if event
      unless event.past?
        render Events::FormComponent.new(
          event: event,
          url: event_path(event),
          method: :patch
        ), status: :ok
      else
        redirect_to events_path, alert: t("events.edit.past_event_error")
      end
    else
      redirect_to events_path, alert: t("events.edit.not_found")
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
    service = Events::Destroy.call(event_id: params[:id])

    if service.success?
      redirect_to events_path, notice: t("events.destroy.success")
    else
      render :not_found, locals: { errors: service.errors }, status: :not_found
    end
  end

  private

  def event_params
    params.require(:event).permit(:name, :description, :place, :date, :category, :image)
  end
end
