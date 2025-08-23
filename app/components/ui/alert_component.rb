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
          "border-info/50 text-info dark:border-info [&>svg]:text-info"
        when :error
          "border-destructive/50 text-destructive dark:border-destructive [&>svg]:text-destructive"
        when :success
          "border-success/50 text-success dark:border-success [&>svg]:text-success"
        when :alert
          "border-attention/50 text-attention dark:border-attention [&>svg]:text-attention"
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
        when :notice then "Wiadomość"
        when :error then "Błąd"
        when :success then "Sukces"
        when :alert then "Uwaga"
        end

      # TODO: remove block argument in case it will turn out to be redundant
      @content = (capture(&block) if block) || description
      @variant = variant

      super()
    end
  end
end
