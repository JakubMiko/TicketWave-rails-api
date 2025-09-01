# frozen_string_literal: true

module Events
  class Update < BaseService
    attr_reader :event, :params

    def initialize(event:, params:)
      super()
      @event = event
      @params = params
    end

    def call
      return unless valid_params?
      event.update(params)
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
