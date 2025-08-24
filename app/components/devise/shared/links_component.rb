# frozen_string_literal: true

module Devise
  module Shared
    class LinksComponent < BaseComponent
      attr_reader :resource_name, :devise_mapping, :controller_name

      def initialize(resource_name:, devise_mapping:, controller_name:)
        @resource_name = resource_name
        @devise_mapping = devise_mapping
        @controller_name = controller_name
      end
    end
  end
end
