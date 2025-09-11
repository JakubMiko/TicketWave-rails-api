class OrdersController < ApplicationController
  before_action :authenticate_user!, except: [ :new, :create, :confirmation ]

  def new
    event = Event.find(params[:event_id])
    ticket_batch = TicketBatch.find(params[:ticket_batch_id])
    order = Order.new

    render Orders::FormComponent.new(
      event: event,
      ticket_batch: ticket_batch,
      order: order,
      current_user:
    ), status: :ok
  end

  def create
    ticket_batch = TicketBatch.find(params[:ticket_batch_id])
    event = ticket_batch.event

    service = Orders::CreateService.new(
      ticket_batch: ticket_batch,
      params: order_params,
      current_user: current_user,
      guest_params: guest_params,
      event: event
    ).call

    if service.success?
      redirect_to confirmation_order_path(service.order), notice: "Order placed successfully."
    else
      flash.now[:alert] = service.errors.join("\n")
      render Orders::FormComponent.new(
        event: event,
        ticket_batch: ticket_batch,
        order: service.order,
        current_user: current_user
      ), status: :unprocessable_entity
    end
  end

  def index
    orders = current_user ? current_user.orders : Order.none

    render Orders::IndexComponent.new(orders: orders)
  end

  def show
    order = Order.includes(:tickets).find(params[:id])

    render Orders::ShowComponent.new(order: order)
  end

  def confirmation
    order = Order.find(params[:id])

    render Orders::ConfirmationComponent.new(order: order)
  end

  private

  def order_params
    params.require(:order).permit(:quantity)
  end

  def guest_params
    params.require(:order).permit(
      :guest_email,
      :guest_password,
      :guest_password_confirmation,
      :guest_first_name,
      :guest_last_name
    )
  end
end
