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

    render Events::DestroyComponent.new(event: event), status: :ok
  end

  def create
    service = CreateEventService.call(params: event_params)

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
        render :edit, locals: { event: event }, status: :ok
      else
        redirect_to events_path, alert: "Nie można edytować wydarzeń, które już się odbyły."
      end
    else
      redirect_to events_path, alert: "Wydarzenie nie zostało znalezione."
    end
  end

  def update
    event = Event.find_by(id: params[:id])

    if event
      contract = EventContract.new
      result = contract.call(event_params.to_h)

      if result.success?
        if event.update(event_params)
          redirect_to events_path, notice: "Wydarzenie zostało zaktualizowane."
        else
          render :edit, locals: { event: event }, status: :unprocessable_entity
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

        render :edit, locals: { event: event }, status: :unprocessable_entity
      end
    else
      render :not_found, status: :not_found
    end
  end

  def destroy
    service = Events::Destroy.call(event_id: params[:id])

    if service.success?
      redirect_to events_path, notice: "Wydarzenie zostało usunięte."
    else
      render :not_found, locals: { errors: service.errors }, status: :not_found
    end
  end

  private

  def event_params
    params.require(:event).permit(:name, :description, :place, :date, :category, :image)
  end
end
