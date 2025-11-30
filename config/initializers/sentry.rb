# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = "https://87c3dae28649e948c6bc46ac5160dd1d@o4510453962178560.ingest.de.sentry.io/4510453963554896"
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]

  # Set environment (defaults to 'development' if RAILS_ENV not set)
  config.environment = Rails.env

  # Enable sending in development (by default Sentry only sends in production)
  config.enabled_environments = %w[development staging production]

  # Add data like request headers and IP for users,
  # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
  config.send_default_pii = true

  # Set traces sample rate (1.0 = 100% of transactions for performance monitoring)
  # In production, use lower value like 0.1 (10%) to reduce overhead
  config.traces_sample_rate = 1.0

  # TEMPORARY: Disable SSL verification for development (REMOVE IN PRODUCTION!)
  config.transport.ssl_verification = false if Rails.env.development?
end
