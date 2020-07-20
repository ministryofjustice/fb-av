require 'date'
require 'sentry-raven'

Raven.configure do |config|
  config.dsn = ENV.fetch('SENTRY_DSN')
end

BYTECODE = 'bytecode.cvd database is up to date'.freeze
DAILY = 'daily.cvd database is up to date'.freeze
MAIN = 'main.cvd database is up to date'.freeze

today = Date.today.strftime("%a %b %d")

todays_log_lines = File.read('/var/log/clamav/freshclam.log')
                       .split("\n")
                       .select { |line| line.include?(today) }


begin
  raise(StandardError, 'THIS WORKS')
  unless todays_log_lines.find { |line| line.include?(BYTECODE) }
    raise(StandardError, 'Bytecode database failed to update')
  end

  unless todays_log_lines.find { |line| line.include?(DAILY) }
    raise(StandardError, 'Daily database failed to update')
  end

  unless todays_log_lines.find { |line| line.include?(MAIN) }
    raise(StandardError, 'Main database failed to update')
  end
rescue StandardError => e
  Raven.capture_exception(e)
end

