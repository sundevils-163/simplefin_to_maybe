#app/lib/cron_scheduler.rb

module CronScheduler
  require 'fugit'
  require 'tzinfo'

  def update_cron_schedule
    cron_expression = Setting.find_by(key: 'synchronization_schedule')&.value || '0 5,23 * * *'
    
    # Get the timezone from the environment, default to UTC
    tz = ENV['TZ'] || 'UTC'
    timezone = TZInfo::Timezone.get(tz)

    # Parse the cron schedule and convert to the selected timezone
    next_run_time_utc = Fugit::Cron.parse(cron_expression).next_time.to_s.to_time.utc
    next_run_time_local = timezone.utc_to_local(next_run_time_utc)

    # Schedule the job with ActiveJob
    RunAllSyncsJob.set(wait_until: next_run_time_local).perform_later
  end
end
