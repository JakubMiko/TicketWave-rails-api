# frozen_string_literal: true

module Events
  class CreateService < BaseService
    attr_reader :event, :params

    def initialize(params:)
      super()
      @params = params
    end

    def call
      @event = Event.new(params)
      return unless valid_params?

      event.save
      event
    end

    private

    def valid_params?
      contract = EventContract.new
      result = contract.call(params.to_h)

      if result.failure?
        errors.concat(
          result.errors.to_h.flat_map do |key, messages|
            Array(messages).map { |msg| "➔ #{key.to_s.humanize} #{msg}" }
          end
        )
      end
      errors.empty?
    end
  end
end
