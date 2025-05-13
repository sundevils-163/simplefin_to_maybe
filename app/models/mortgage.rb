#app/models/mortgage.rb

class Mortgage < ApplicationRecord
  include CronScheduler  #app/lib/cron_scheduler.rb

  belongs_to :maybe_account, class_name: "Account", foreign_key: "maybe_account_id"
  after_initialize :set_defaults, unless: :persisted?
  after_create :update_cron_schedule_after_create

  def update_cron_schedule_after_create
    update_cron_schedule(RunAllMortgagesJob)  #app/lib/cron_scheduler.rb
  end

  def sync
    Rails.logger.info "Queuing sync for #{self.id}"
    if self.enabled?
      MortgageTransactionJob.perform_later(self)
    end
  end

  private

  def set_defaults
    self.day_of_month ||= 1
  end
end
