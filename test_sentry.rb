#!/usr/bin/env ruby

# Load Rails environment
require_relative 'config/environment'

puts "Testing Sentry integration..."
puts "Environment: #{Rails.env}"
puts "Sentry enabled: #{Sentry.configuration.enabled_environments.include?(Rails.env)}"
puts ""

# Test 1: Simple message
puts "1. Capturing test message..."
event_id = Sentry.capture_message("Test message from TicketWave development", level: :info)
puts "   Event ID: #{event_id}"

# Test 2: ZeroDivisionError
begin
  1 / 0
rescue ZeroDivisionError => exception
  puts "2. Capturing ZeroDivisionError..."
  event_id = Sentry.capture_exception(exception)
  puts "   Event ID: #{event_id}"
end

# Test 3: Custom error
begin
  raise StandardError, "Custom test error from TicketWave"
rescue StandardError => e
  puts "3. Capturing custom error..."
  event_id = Sentry.capture_exception(e)
  puts "   Event ID: #{event_id}"
end

puts ""
puts "✅ Test complete!"
puts "Note: Events are sent asynchronously. Check your Sentry dashboard in a few seconds."
puts "Dashboard: https://sentry.io/"
