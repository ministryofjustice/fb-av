require 'date'
require 'sentry-raven'
require 'rufus-scheduler'
require 'logger'

logger = Logger.new('/var/log/clamav/clamav_check.log')

Raven.configure do |config|
  config.dsn = ENV.fetch('SENTRY_DSN')
end

FRESHCLAM_LOG_FILE = '/var/log/clamav/freshclam.log'.freeze
UPDATE_TYPES = {
  bytecode: /(bytecode.cld|bytecode.cvd) (database is (up-to-date|updated|up to date))/,
  daily: /(daily.cld|daily.cvd) (database is (up-to-date|updated|up to date))/,
  main: /(main.cld|main.cvd) (database is (up-to-date|updated|up to date))/
}

scheduler = Rufus::Scheduler.new

scheduler.cron '50 15 * * *' do
  logger.info('Starting check')

  today = Date.today
  day_format = today.day < 10 ? ' %-d' : '%d'
  formatted_today = today.strftime("%a %b #{day_format}")

  begin
    todays_log_lines = File.read(FRESHCLAM_LOG_FILE)
                           .split("\n")
                           .select { |line| line.include?(formatted_today) }

    UPDATE_TYPES.each do |type, regex|
      unless todays_log_lines.find { |line| line.match(regex) }
        message = "#{type} database failed to update for #{formatted_today}"
        logger.info(message)
        raise(StandardError, message)
      end
    end

    logger.info("Everything is up to date for #{formatted_today}")
  rescue StandardError => e
    Raven.capture_exception(e)
  end
end

scheduler.join
