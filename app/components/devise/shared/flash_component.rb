# frozen_string_literal: true

module Devise
  module Shared
    class FlashComponent < ViewComponent::Base
      def initialize(flash:)
        @flash = flash
      end

      def call
        safe_join(
          @flash.to_h.map do |variant, description|
            Ui::AlertComponent.new(variant:, description:).render_in(view_context)
          end
        )
      end
    end
  end
end
