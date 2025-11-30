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

    # Example 3: SET TAGS - Tagging for filtering in Sentry
    Sentry.set_tags(
      service: "orders_create",
      event_id: event.id,
      has_user: current_user.present?,
      ticket_batch_id: ticket_batch.id
    )

    # Example 2: SET EXTRAS - Additional context data
    Sentry.set_extras(
      ticket_batch_price: ticket_batch.price,
      available_tickets: ticket_batch.available_tickets,
      event_name: event.name
    )

    # Example 1: BREADCRUMB - Tracking user actions
    Sentry.add_breadcrumb(
      Sentry::Breadcrumb.new(
        message: "User initiated order",
        category: "user_action",
        data: { event_name: event.name, quantity: order_params[:quantity] }
      )
    )

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
      # Example 6: CAPTURE MESSAGE - Capture service failure
      Sentry.capture_message("Order creation failed", level: :error)

      flash.now[:alert] = service.errors.join("\n")
      render Orders::FormComponent.new(
        event: event,
        ticket_batch: ticket_batch,
        order: service.order || Order.new(order_params),
        current_user: current_user
      ), status: :unprocessable_content
    end
  end

  def index
    orders = current_user ? current_user.orders : Order.none

    render Orders::IndexComponent.new(orders: orders)
  end

  def show
    # Example 7: PERFORMANCE MONITORING - Track database query performance
    span = Sentry.get_current_scope.get_span&.start_child(
      op: "db.query",
      description: "Load order with tickets"
    )

    order = Order.includes(:tickets).find(params[:id])

    span&.finish

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
