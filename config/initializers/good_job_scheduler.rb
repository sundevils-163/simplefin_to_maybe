# config/initializers/good_job_scheduler.rb
require 'fugit'

# Skip this logic during assets precompilation
if !defined?(Rails.application.assets)
  Rails.application.config.after_initialize do
    # Method to update the cron job schedule
    def update_cron_schedule
      cron_expression = Setting.find_by(key: 'synchronization_schedule')&.value || '0 5,23 * * *'
      next_run_time = Fugit::Cron.parse(cron_expression).next_time.to_s.to_time

      # Schedule the job with ActiveJob
      RunAllSyncsJob.set(wait_until: next_run_time).perform_later
    end

    # Call update_cron_schedule inside after_initialize
    update_cron_schedule
  end
end
