# frozen_literal_string: true

module Shared
  class HeaderComponent < BaseComponent
    attr_reader :current_user

    def initialize(current_user:)
      @current_user = current_user
    end
  end
end
