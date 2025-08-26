# frozen_string_literal: true

module Events
  class FormComponent < BaseComponent
    attr_reader :event, :url, :method

    def initialize(event:, url:, method:)
      @event = event
      @url = url
      @method = method
    end
  end
end
