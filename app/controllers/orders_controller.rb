class OrdersController < ApplicationController
  before_action :authenticate_user!, except: [ :new, :create ], unless: :admin_signed_in?

  def new
    event = Event.find(params[:event_id])
    ticket_batch = TicketBatch.find(params[:ticket_batch_id])
    order = Order.new

    # Check if either a regular user or admin is signed in
    user = if user_signed_in?
             current_user
    elsif admin_signed_in?
             current_admin
    else
             nil
    end

    render :new, locals: {
      event: event,
      ticket_batch: ticket_batch,
      order: order,
      user: user
    }, status: :ok
  end

  def create
    ticket_batch = TicketBatch.find(params[:ticket_batch_id])
    event = ticket_batch.event

    quantity = order_params[:quantity].to_i

    if quantity <= 0
      redirect_to event_path(event), alert: "Nieprawidłowa liczba biletów."
      return
    end

    if quantity > ticket_batch.available_tickets
      redirect_to event_path(event), alert: "Nie ma wystarczającej liczby biletów. Dostępnych: #{ticket_batch.available_tickets}"
      return
    end

    order = Order.new(order_params)
    order.ticket_batch = ticket_batch
    order.total_price = ticket_batch.price * quantity
    order.status = "completed"

    if admin_signed_in?
      # Admin jest zalogowany
      order.user = current_admin
    elsif user_signed_in?
      # Zwykły użytkownik jest zalogowany
      order.user = current_user
    elsif params[:guest_email].present? && params[:guest_password].present?
      # Zakup z utworzeniem konta
      if params[:guest_password] != params[:guest_password_confirmation]
        flash.now[:alert] = "Podane hasła nie są identyczne."
        render :new, locals: { event: event, ticket_batch: ticket_batch, order: order, user: nil }, status: :unprocessable_entity
        return
      end

      # Sprawdź, czy użytkownik o podanym emailu już istnieje
      existing_user = User.find_by(email: params[:guest_email])
      if existing_user
        flash.now[:alert] = "Użytkownik z tym adresem email już istnieje. Zaloguj się, aby kontynuować."
        render :new, locals: { event: event, ticket_batch: ticket_batch, order: order, user: nil }, status: :unprocessable_entity
        return
      end

      # Utwórz nowego użytkownika
      guest_user = User.new(
        email: params[:guest_email],
        password: params[:guest_password],
        password_confirmation: params[:guest_password_confirmation],
        first_name: params[:guest_first_name],
        last_name: params[:guest_last_name],
        role: "user"
      )

      if guest_user.save
        sign_in(guest_user)
        order.user = guest_user
      else
        flash.now[:alert] = "Nie udało się utworzyć konta: #{guest_user.errors.full_messages.join(', ')}"
        render :new, locals: { event: event, ticket_batch: ticket_batch, order: order, user: guest_user }, status: :unprocessable_entity
        return
      end
    else
      # Brak danych
      flash.now[:alert] = "Musisz podać dane osobowe lub zalogować się, aby kupić bilet."
      render :new, locals: { event: event, ticket_batch: ticket_batch, order: order, user: nil }, status: :unprocessable_entity
      return
    end

    # Proces zamówienia
    ActiveRecord::Base.transaction do
      if order.save
        ticket_batch.available_tickets -= quantity
        ticket_batch.save!

        quantity.times do
          ticket = Ticket.new(
            order: order,
            user: order.user,
            event: event,
            price: ticket_batch.price,
            ticket_number: "#{event.id}-#{SecureRandom.hex(4)}"
          )
          ticket.save!
        end

        redirect_to confirmation_order_path(order), notice: "Zamówienie zostało złożone pomyślnie."
      else
        flash.now[:alert] = "Nie udało się zapisać zamówienia: #{order.errors.full_messages.join(', ')}"
        render :new, locals: { event: event, ticket_batch: ticket_batch, order: order, user: nil }, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = "Wystąpił błąd podczas przetwarzania zamówienia: #{e.message}"
    render :new, locals: { event: event, ticket_batch: ticket_batch, order: order, user: nil }, status: :unprocessable_entity
  end

  def confirmation
    order = Order.find(params[:id])

    # Allow both regular users and admins to access their orders
    if (user_signed_in? && order.user != current_user) &&
       (admin_signed_in? && order.user != current_admin)
      redirect_to events_path, alert: "Nie masz dostępu do tego zamówienia."
      return
    end

    render :confirmation, locals: { order: order }, status: :ok
  end

  def index
    orders = current_user ? current_user.orders : Order.none

    render Orders::IndexComponent.new(orders: orders)
  end

  def show
    order = Order.includes(:tickets).find(params[:id])

    render Orders::ShowComponent.new(order: order)
  end

  private

  def order_params
    params.require(:order).permit(:quantity)
  end
end
