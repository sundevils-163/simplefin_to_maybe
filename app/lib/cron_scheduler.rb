#app/lib/cron_scheduler.rb

module CronScheduler
  require 'fugit'
  require 'tzinfo'

  def update_cron_schedule(job_class)

    cron_expression = Setting.find_by(key: 'synchronization_schedule')&.value || '0 5,23 * * *'
  
    # Get the timezone from the environment, default to UTC
    tz = ENV['TZ'] || 'UTC'
    timezone = TZInfo::Timezone.get(tz)
  
    # Parse the cron schedule and convert to the selected timezone
    next_run_time_utc = Fugit::Cron.parse(cron_expression).next_time.to_s.to_time.utc
    next_run_time_local = timezone.utc_to_local(next_run_time_utc)
  
    # Remove any existing scheduled jobs that don't match this schedule
    delete_unscheduled_jobs(job_class, next_run_time_local)
  
    # Schedule the job with ActiveJob
    job_class.set(wait_until: next_run_time_local).perform_later
  end

  def delete_unscheduled_jobs(job_class, correct_time)
    GoodJob::Job
      .where(queue_name: 'default', job_class: job_class.name)
      .where("scheduled_at > ?", Time.current)  # Only delete future jobs
      .where.not(scheduled_at: correct_time)
      .destroy_all
  end
  
end
