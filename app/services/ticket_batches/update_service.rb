# frozen_string_literal: true

module TicketBatches
  class UpdateService < BaseService
    attr_reader :event, :ticket_batch, :params

    def initialize(event:, ticket_batch:, params:)
      super()
      @event = event
      @ticket_batch = ticket_batch
      @params = params
    end

    def call
      return self unless valid_params?
      unless ticket_batch.update(params)
        errors.concat(ticket_batch.errors.full_messages)
      end
      self
    end

    private

    def valid_params?
      validation = TicketBatchContract.new(
        event: event,
        existing_batches: event.ticket_batches.where.not(id: nil)
      ).call(params.to_h.merge(id: ticket_batch.id))

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
