# frozen_string_literal: true

module TicketBatches
  class CreateService < BaseService
    attr_reader :event, :params, :ticket_batch

    def initialize(event:, params:)
      super()
      @event = event
      @params = params
      @ticket_batch = event.ticket_batches.new(params)
    end

    def call
      return self unless valid_params?
      ticket_batch.save
      self
    end

    private

    def valid_params?
      validation = TicketBatchContract.new(
        event: event,
        existing_batches: event.ticket_batches.where.not(id: nil)
      ).call(params.to_h)

      if validation.failure?
        errors.concat(
          validation.errors.map do |err|
            key = err.path.empty? ? "" : "#{err.path.first.to_s.humanize} "
            "➔ #{key}#{err.text}"
          end
        )
      end

      errors.empty?
    end
  end
end
