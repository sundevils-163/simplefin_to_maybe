# app/jobs/sync_linkage_job.rb

class SyncLinkageJob < ApplicationJob
  queue_as :default

  def perform(linkage)

    linkage.update(sync_status: :running)
    
    maybe_account = Account.find_by(id: linkage.maybe_account_id)
    simplefin_account = Account.find_by(id: linkage.simplefin_account_id)

    maybe_client = MaybeClientService.connect
    if maybe_client.nil?
      linkage.update(sync_status: :error, last_sync: Time.current)
      return
    end

    username = Setting.find_by(key: 'simplefin_username')&.value
    password = Setting.find_by(key: 'simplefin_password')&.value

    if username.blank? || password.blank?
      Rails.logger.warn "Missing SimpleFIN username or password!"
      linkage.update(sync_status: :error, last_sync: Time.current)
      return
    else
      simplefin_client = SimplefinClient.new(username, password)
    end

    if maybe_account.accountable_type == "Investment"
      simplefin_response = simplefin_client.get_account(simplefin_account.identifier) 
      if simplefin_response[:success]
        simplefin_account_with_balance = simplefin_response[:response].dig("accounts").first
        maybe_client.upsert_account_valuation(maybe_account.identifier, simplefin_account_with_balance)
      end
    else  #CreditCard,Despository,Loan
      lookback_days = Setting.find_by(key: 'lookback_days')&.value || 7
      start_date = (Time.now - (lookback_days * 24 * 60 * 60)).to_i
      transactions_in_maybe = maybe_client.get_simplefin_transactions(maybe_account.identifier, start_date)
      simplefin_response = simplefin_client.get_transactions(simplefin_account.identifier, start_date)
      
      if simplefin_response[:success]
        simplefin_transactions = simplefin_response[:response].dig("accounts").first&.dig("transactions") || []
        
          # Early return if transactions are the same
        if simplefin_transactions.length == transactions_in_maybe.length
          linkage.update(sync_status: :complete, last_sync: Time.current)
          return
        end
    
        simplefin_transactions.each do |simplefin_transaction|
          transaction_id = simplefin_transaction.dig("id")
    
          # If this transaction hasn't been synced yet, create a new transaction in Maybe
          unless transactions_in_maybe.any? { |t| t["plaid_id"] == transaction_id }
            maybe_client.new_transaction(maybe_account.identifier, simplefin_transaction, simplefin_account.simplefin_id_sanitized, simplefin_account.currency)
          end
        end
      else
        Rails.logger.error("Failed to fetch transactions from SimpleFin API")
        linkage.update(sync_status: :error, last_sync: Time.current)
      end
    end
   
    linkage.update(sync_status: :complete, last_sync: Time.current)
  end
end
  