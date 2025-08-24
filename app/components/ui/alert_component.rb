module Ui
  class AlertComponent < BaseComponent
    AVAILABLE_VARIANTS = [ :notice, :error, :success, :alert ]

    attr_reader :alert_classes, :alert_testid, :title, :content, :variant

    def initialize(description: nil, variant: :default, &block)
      variant = variant.to_sym
      raise "Unhandled variant type: #{variant}" unless variant.in?(AVAILABLE_VARIANTS)

      @alert_classes =
        case variant
        when :notice
          "border-blue-300 bg-blue-50 text-blue-800"
        when :error
          "border-red-300 bg-red-50 text-red-800"
        when :success
          "border-green-300 bg-green-50 text-green-800"
        when :alert
          "border-yellow-300 bg-yellow-50 text-yellow-800"
        end

      @alert_testid =
        case variant
        when :notice
          "alert-success"
        when :error
          "alert-error"
        when :success
          "alert-success"
        when :alert
          "alert-alert"
        end

      @title =
        case variant
        when :notice then "Notification"
        when :error then "Error"
        when :success then "Success"
        when :alert then "Caution"
        end

      # TODO: remove block argument in case it will turn out to be redundant
      @content = (capture(&block) if block) || description
      @variant = variant

      super()
    end
  end
end
