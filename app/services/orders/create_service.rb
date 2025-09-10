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
      return self unless valid_params?

      @order = build_order
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
      ticket_batch.update!(available_tickets: available_tickets_after_order)
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
