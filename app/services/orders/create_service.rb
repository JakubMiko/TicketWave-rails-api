# frozen_string_literal: true

module Orders
  class CreateService < BaseService
    attr_reader :ticket_batch, :params, :current_user, :event, :order, :guest_params

    def initialize(ticket_batch:, params:, current_user:, event:, guest_params:)
      super()
      @ticket_batch = ticket_batch
      @params = params
      @current_user = current_user
      @event = event
      @guest_params = guest_params
      @order = nil
    end

    def call
      # Example 1: BREADCRUMB - Tracking execution steps
      Sentry.add_breadcrumb(
        Sentry::Breadcrumb.new(
          message: "Order creation started",
          category: "service",
          data: { quantity: params[:quantity], ticket_batch_id: ticket_batch.id }
        )
      )

      return self unless valid_params?

      @order = build_order

      # Example 1: BREADCRUMB - Tracking execution steps
      Sentry.add_breadcrumb(
        Sentry::Breadcrumb.new(
          message: "Order build",
          category: "service",
          data: { total_price: @order.total_price }
        )
      )

      # TEMPORARY: Force error to test breadcrumbs in Sentry
      raise StandardError, "Testing breadcrumbs" if Rails.env.development?

      assign_user!

      ActiveRecord::Base.transaction do
        save_order_and_tickets
      end
      self
    end

    private

    def valid_params?
      validation_result = OrderContract.new.call(params.to_h.merge(ticket_batch: ticket_batch))
      if validation_result.failure?
        # Example 6: CAPTURE MESSAGE - Messages with level and extras
        # Use constant text so all validation failures group together in Sentry
        Sentry.capture_message(
          "Order validation failed",
          level: :warning,
          extra: {
            validation_errors: validation_result.errors.to_h,
            params: params.to_h,
            ticket_batch_id: ticket_batch.id
          }
        )

        errors.concat(
          validation_result.errors.to_h.flat_map do |key, messages|
            Array(messages).map { |msg| "➔ #{key.to_s.humanize} #{msg.capitalize}" }
          end
        )
      end
      errors.empty?
    end

    def build_order
      order = Order.new(params.slice(:quantity))
      order.ticket_batch = ticket_batch
      order.total_price = calculate_total_price(order)
      order.status = "completed"
      order
    end

    def calculate_total_price(order)
      ticket_batch.price * order.quantity
    end

    def assign_user!
      if current_user
        @order.user = current_user
      elsif guest_params[:guest_email].present? && guest_params[:guest_password].present?
        user_params = {
          email: guest_params[:guest_email],
          password: guest_params[:guest_password],
          password_confirmation: guest_params[:guest_password_confirmation],
          first_name: guest_params[:guest_first_name],
          last_name: guest_params[:guest_last_name],
          admin: false
        }

        validation = UserContract.new.call(user_params)
        if validation.success?
          guest_user = User.create(user_params)
          @order.user = guest_user
        else
          errors.concat(
            validation.errors.to_h.flat_map do |key, messages|
              Array(messages).map { |msg| "➔ #{key.to_s.humanize} #{msg.capitalize}" }
            end
          )
        end
      else
        errors << "➔ User must be present"
      end
    end

    def save_order_and_tickets
      if @order.user.nil?
        # Example 2: SET EXTRAS - Additional context data
        Sentry.set_extras(
          ticket_batch_id: ticket_batch.id,
          event_id: event.id,
          order_quantity: @order.quantity,
          guest_email: guest_params[:guest_email]
        )

        Sentry.capture_message("Order save failed: user missing", level: :error)

        errors << "➔ User must exist"
        return
      end

      if @order.save
        update_ticket_batch!
        create_tickets!
      else
        errors.concat(@order.errors.full_messages)
      end
    end

    def update_ticket_batch!
      # Example 5: CAPTURE EXCEPTION - Catching specific errors
      begin
        ticket_batch.update!(available_tickets: available_tickets_after_order)
      rescue ActiveRecord::RecordInvalid => e
        Sentry.capture_exception(e, extra: {
          ticket_batch_id: ticket_batch.id,
          current_available: ticket_batch.available_tickets,
          attempted_new_value: available_tickets_after_order,
          order_quantity: @order.quantity
        })
        raise # Re-raise to maintain transaction rollback
      end
    end

    def available_tickets_after_order
      ticket_batch.available_tickets - @order.quantity.to_i
    end

    def create_tickets!
      @order.quantity.to_i.times do
        Ticket.create!(
          order: @order,
          user: @order.user,
          event: event,
          price: ticket_batch.price,
          ticket_number: "#{event.id}-#{SecureRandom.hex(4)}"
        )
      end
    end
  end
end
