class EventsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy ]

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
    render Events::FormComponent.new(
      event: event,
      url: events_path,
      method: :post
    ), status: :ok
  end

  def create
    service = Events::Create.call(params: event_params)
    if service.success?
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

    service = Events::Update.call(event: event, params: event_params)
    if service.success?
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
