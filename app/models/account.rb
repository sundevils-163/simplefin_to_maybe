class Account < ApplicationRecord
  enum account_type: {simplefin: "simplefin", maybe: "maybe"}
  validates :account_type, presence: true, inclusion: { in: account_types.keys }

  has_one :simplefin_linkage, class_name: "Linkage", foreign_key: "simplefin_account_id"
  has_one :maybe_linkage, class_name: "Linkage", foreign_key: "maybe_account_id"
end
