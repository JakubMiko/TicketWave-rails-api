# frozen_string_literal: true

class TicketBatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def new
    event = Event.find(params[:event_id])
    ticket_batch = TicketBatch.new(event: event)

    render TicketBatches::FormComponent.new(event: event, ticket_batch: ticket_batch)
  end

  def create
    event = Event.find(params[:event_id])
    service = TicketBatches::CreateService.new(event:, params: ticket_batch_params).call

    if service.success?
      flash.now[:notice] = "Ticket batch created."
      list_html = view_context.render(
        Events::TicketBatchesComponent.new(event: event.reload, current_user: current_user)
      )
      render turbo_stream: [
        turbo_stream.replace("ticket_batches_list", list_html),
        turbo_stream.update("modal_frame", "")
      ]
    else
      alert_html = view_context.render(
        Ui::AlertComponent.new(description: service.errors.join("<br>"), variant: :error)
      )
      render turbo_stream: turbo_stream.update("modal_alert", alert_html), status: :unprocessable_content
    end
  end

  def edit
    event = Event.find(params[:event_id])
    ticket_batch = event.ticket_batches.find(params[:id])

    render TicketBatches::FormComponent.new(event: event, ticket_batch: ticket_batch)
  end

  def update
    event = Event.find(params[:event_id])
    ticket_batch = event.ticket_batches.find(params[:id])

    service = TicketBatches::UpdateService.new(event:, ticket_batch:, params: ticket_batch_params).call

    if service.success?
      flash.now[:notice] = "Ticket batch updated"
      list_html = view_context.render(
        Events::TicketBatchesComponent.new(event: event.reload, current_user: current_user)
      )

      render turbo_stream: [
        turbo_stream.replace("ticket_batches_list", list_html),
        turbo_stream.update("modal_frame", "")
      ]
    else
      alert_html = view_context.render(
        Ui::AlertComponent.new(description: service.errors.join("<br>"), variant: :error)
      )
      render turbo_stream: turbo_stream.update("modal_alert", alert_html), status: :unprocessable_content
    end
  end

  def destroy
    event = Event.find(params[:event_id])
    ticket_batch = event.ticket_batches.find(params[:id])
    ticket_batch.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(view_context.dom_id(ticket_batch)) }
      format.html { redirect_to event_path(event), notice: t("ticket_batches.destroy.success") }
    end
  end

  private

  def ticket_batch_params
    params.require(:ticket_batch).permit(:available_tickets, :price, :sale_start, :sale_end)
  end

  def authorize_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end
end
