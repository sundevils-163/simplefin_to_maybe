class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  after_update :update_cron_schedule_if_needed

  private

  def update_cron_schedule_if_needed
    if self.key == 'synchronization_schedule' && saved_change_to_value?
      # Call the method to update the cron job schedule when the setting changes
      update_cron_schedule
    end
  end
end
