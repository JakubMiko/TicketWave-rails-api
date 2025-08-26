module Events
  class Create < BaseService
    attr_reader :params, :event

    def initialize(params:)
      super()
      @params = event_params
      @event = Event.new(params)
    end

    def call
      validate_params
      return if failure?

      save_event
    end

    private

    def validate_params
      contract = EventContract.new
      result = contract.call(params.to_h)

      if result.success?
        true
      else
        result.errors.to_h.each do |key, messages|
          Array(messages).each do |message|
            event.errors.add(key.presence || :base, message)
          end
        end
        errors.concat(event.errors.full_messages)
      end
    end

    def save_event
      unless event.save
        errors.concat(event.errors.full_messages)
      end
    end
  end
end
