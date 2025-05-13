#app/models/setting.rb

class Setting < ApplicationRecord
  include CronScheduler  #app/lib/cron_scheduler.rb

  validates :key, presence: true, uniqueness: true

  after_update :update_cron_schedule_if_needed

  def update_cron_schedule_if_needed
    if self.key == 'synchronization_schedule' && saved_change_to_value?
      # Call the method to update the cron job schedule when the setting changes
      update_cron_schedule(RunAllSyncsJob)
      update_cron_schedule(RunAllMortgagesJob)
    end
  end
end
