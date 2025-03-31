class Linkage < ApplicationRecord
  belongs_to :simplefin_account, class_name: "Account", foreign_key: "simplefin_account_id"
  belongs_to :maybe_account, class_name: "Account", foreign_key: "maybe_account_id"

  enum sync_status: {initialized: "initialized", pending: "pending", running: "running", complete: "complete", error: "error"}
  validates :sync_status, inclusion: { in: sync_statuses.keys }

  after_initialize :set_default_sync_status, if: :new_record?

  def sync
    Rails.logger.info "Queuing sync for #{self.id}"
    if self.enabled?
      update(sync_status: :pending)
      SyncLinkageJob.perform_later(self)
    end
  end

  private

  def set_default_sync_status
    self.sync_status ||= :initialized
  end

end  