# Will require the user to update settings after each restart...
#
#
## config/initializers/good_job_scheduler.rb
#
## Skip this logic during assets precompilation
#if !defined?(Rails.application.assets)
#  Rails.application.config.after_initialize do
#
#    Rails.logger.info "Initializing GoodJob Scheduler"
#
#    # Ensure the CronScheduler module is loaded
#    require_dependency 'cron_scheduler'  #app/lib/cron_scheduler.rb
#
#    # Call the method from the CronScheduler module
#    CronScheduler.update_cron_schedule
#  end
#end
