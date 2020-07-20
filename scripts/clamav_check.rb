require 'date'
require 'sentry-raven'
require 'rufus-scheduler'
require 'logger'

logger = Logger.new('/var/log/clamav/clamav_check.log')

Raven.configure do |config|
  config.dsn = ENV.fetch('SENTRY_DSN')
end

FRESHCLAM_LOG_FILE = '/var/log/clamav/freshclam.log'.freeze
BYTECODE = /bytecode.cvd (database is up to date|updated)/.freeze
DAILY = /daily.cld (database is up to date|updated)/.freeze
MAIN = /main.cvd (database is up to date|updated)/.freeze

scheduler = Rufus::Scheduler.new

scheduler.cron '30 15 * * *' do
  logger.info('Starting check')

  today = Date.today.strftime("%a %b %d")
  begin
    todays_log_lines = File.read(FRESHCLAM_LOG_FILE)
                           .split("\n")
                           .select { |line| line.include?(today) }

    unless todays_log_lines.find { |line| line.match(BYTECODE) }
      raise(StandardError, "Bytecode database failed to update -> #{Time.now}")
    end

    unless todays_log_lines.find { |line| line.match(DAILY) }
      raise(StandardError, "Daily database failed to update -> #{Time.now}")
    end

    unless todays_log_lines.find { |line| line.match(MAIN) }
      raise(StandardError, "Main database failed to update -> #{Time.now}")
    end

    logger.info('Everything is up to date')
  rescue StandardError => e
    Raven.capture_exception(e)
  end
end

scheduler.join
