class Linkage < ApplicationRecord
  belongs_to :simplefin_account, class_name: "Account", foreign_key: "simplefin_account_id"
  belongs_to :maybe_account, class_name: "Account", foreign_key: "maybe_account_id"
end  