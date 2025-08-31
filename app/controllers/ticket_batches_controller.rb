class TicketBatchesController < ApplicationController
  def new
    event = Event.find(params[:event_id])
    ticket_batch = TicketBatch.new(event: event)

    render TicketBatches::FormComponent.new(event: event, ticket_batch: ticket_batch)
  end

  def create
    event = Event.find(params[:event_id])

    contract = TicketBatchContract.new(event: event, existing_batches: event.ticket_batches)
    validation = contract.call(ticket_batch_params.to_h)

    if validation.success?
      ticket_batch = event.ticket_batches.new(ticket_batch_params)

      if ticket_batch.save
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace("ticket_batches_list",
                partial: "events/ticket_batches_list",
                locals: { event: event.reload }
              ),
              turbo_stream.update("modal_frame", "")
            ]
          end
          format.html { redirect_to event_path(event), notice: "Pula biletów została dodana." }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.update("modal_frame",
              template: "ticket_batches/new",
              locals: {
                event: event,
                ticket_batch: ticket_batch,
                validation_errors: ticket_batch.errors.to_h
              }
            ), status: :unprocessable_entity
          end
          format.html do
            flash.now[:alert] = ticket_batch.errors.full_messages.join(", ")
            render :new, locals: { event: event, ticket_batch: ticket_batch, validation_errors: ticket_batch.errors.to_h }, status: :unprocessable_entity
          end
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("modal_frame",
            template: "ticket_batches/new",
            locals: {
              event: event,
              ticket_batch: TicketBatch.new(ticket_batch_params.merge(event: event)),
              validation_errors: validation.errors.to_h
            }
          ), status: :unprocessable_entity
        end
        format.html do
          ticket_batch = TicketBatch.new(ticket_batch_params.merge(event: event))
          flash.now[:alert] = validation.errors.to_h.values.flatten.join(", ")
          render :new, locals: { event: event, ticket_batch: ticket_batch, validation_errors: validation.errors.to_h }, status: :unprocessable_entity
        end
      end
    end
  end

  def edit
    event = Event.find(params[:event_id])
    ticket_batch = event.ticket_batches.find(params[:id])

    render :edit, locals: { event: event, ticket_batch: ticket_batch, validation_errors: {} }
  end

  def update
    event = Event.find(params[:event_id])
    ticket_batch = event.ticket_batches.find(params[:id])

    contract = TicketBatchContract.new(event: event, existing_batches: event.ticket_batches)
    validation = contract.call(ticket_batch_params.to_h.merge(id: ticket_batch.id))

    if validation.success?
      if ticket_batch.update(ticket_batch_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace("ticket_batches_list",
                partial: "events/ticket_batches_list",
                locals: { event: event.reload }
              ),
              turbo_stream.update("modal_frame", "")
            ]
          end
          format.html { redirect_to event_path(event), notice: "Pula biletów została zaktualizowana." }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            # Render the entire edit.html.erb template within the modal frame
            render turbo_stream: turbo_stream.update("modal_frame",
              template: "ticket_batches/edit",
              locals: {
                event: event,
                ticket_batch: ticket_batch,
                validation_errors: ticket_batch.errors.to_h
              }
            ), status: :unprocessable_entity
          end
          format.html do
            render :edit, locals: { event: event, ticket_batch: ticket_batch, validation_errors: ticket_batch.errors.to_h }, status: :unprocessable_entity
          end
        end
      end
    else
      validation_errors = validation.errors.to_h

      respond_to do |format|
        format.turbo_stream do
          # Render the entire edit.html.erb template within the modal frame
          render turbo_stream: turbo_stream.update("modal_frame",
            template: "ticket_batches/edit",
            locals: {
              event: event,
              ticket_batch: ticket_batch,
              validation_errors: validation_errors
            }
          ), status: :unprocessable_entity
        end
        format.html do
          render :edit, locals: { event: event, ticket_batch: ticket_batch, validation_errors: validation_errors }, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    event = Event.find(params[:event_id])
    ticket_batch = event.ticket_batches.find(params[:id])
    ticket_batch.destroy

    redirect_to event_path(event), notice: "Pula biletów została usunięta."
  end

  private

  def ticket_batch_params
    params.require(:ticket_batch).permit(:available_tickets, :price, :sale_start, :sale_end)
  end
end
