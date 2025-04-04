# app/jobs/sync_linkage_job.rb

class SyncLinkageJob < ApplicationJob
  include JobLogger  #app/lib/job_logger.rb

  queue_as :default

  def perform(linkage)

    Rails.logger.info "Logger class: #{logger.class.name}"

    logger.tagged("SyncLinkageJob") { logger.info "[#{linkage.id}] Begin Linkage Sync"}
    logger.tagged("SyncLinkageJob") { logger.info "[#{linkage.id}] Setting Linkage Status to 'Running'"}
    linkage.update(sync_status: :running)
    
    maybe_account = Account.find_by(id: linkage.maybe_account_id)
    logger.tagged("SyncLinkageJob") { logger.error "[#{linkage.id}] Maybe Account: '#{maybe_account.display_name}' [#{maybe_account.identifier}]; Type: #{maybe_account.accountable_type}"}
    simplefin_account = Account.find_by(id: linkage.simplefin_account_id)
    logger.tagged("SyncLinkageJob") { logger.error "[#{linkage.id}] SimpleFIN Account: '#{simplefin_account.display_name}' [#{simplefin_account.identifier}]"}

    maybe_client = MaybeClientService.connect
    if maybe_client.nil?
      logger.tagged("SyncLinkageJob") { logger.error "[#{linkage.id}] Failed to connect to Maybe PostgreSQL"}
      logger.tagged("SyncLinkageJob") { logger.info "[#{linkage.id}] Setting Linkage Status to 'Error'"}
      linkage.update(sync_status: :error, last_sync: Time.current)
      maybe_client.close
      return
    end

    username = Setting.find_by(key: 'simplefin_username')&.value
    password = Setting.find_by(key: 'simplefin_password')&.value

    if username.blank? || password.blank?
      Rails.logger.warn "Missing SimpleFIN username or password!"
      logger.tagged("SyncLinkageJob") { logger.error "[#{linkage.id}] Missing credentials for SimpleFIN"}
      logger.tagged("SyncLinkageJob") { logger.info "[#{linkage.id}] Setting Linkage Status to 'Error'"}
      linkage.update(sync_status: :error, last_sync: Time.current)
      maybe_client.close
      return
    else
      simplefin_client = SimplefinClient.new(username, password)
    end

    lookback_days = Setting.find_by(key: 'lookback_days')&.value.to_i
    lookback_days = 7 if lookback_days.zero?  # Fallback to 7 if the value is nil or non-numeric
    lookback_date = (Time.now - (lookback_days * 24 * 60 * 60))
    start_date = lookback_date.to_i

    logger.tagged("SyncLinkageJob") { logger.info "[#{linkage.id}] Searching for Maybe transactions since #{lookback_date.strftime("%m/%d/%Y")}"}
    transactions_in_maybe = maybe_client.get_simplefin_transactions(maybe_account.identifier, start_date)
    logger.tagged("SyncLinkageJob") { logger.info "[#{linkage.id}] Retrieved #{transactions_in_maybe.length} Maybe transactions"}
    simplefin_response = simplefin_client.get_transactions(simplefin_account.identifier, start_date)
    logger.tagged("SyncLinkageJob") { logger.info "[#{linkage.id}] Searching for SimpleFIN transactions since #{lookback_date.strftime("%m/%d/%Y")}"}
    
    if simplefin_response[:success]
      simplefin_account_with_balance = simplefin_response[:response].dig("accounts").first
      simplefin_transactions = simplefin_response[:response].dig("accounts").first&.dig("transactions") || []
      logger.tagged("SyncLinkageJob") { logger.info "[#{linkage.id}] Retrieved #{simplefin_transactions.length} SimpleFIN transactions"}
      
        # Early return if transactions are the same
      if simplefin_transactions.length == transactions_in_maybe.length
        logger.tagged("SyncLinkageJob") { logger.info "[#{linkage.id}] Transaction counts are equal!"}
        logger.tagged("SyncLinkageJob") { logger.info "[#{linkage.id}] Setting Linkage Status to 'Complete'"}
        linkage.update(sync_status: :complete, last_sync: Time.current)
        maybe_client.close
        return
      end
  
      simplefin_transactions.each do |simplefin_transaction|
        transaction_id = simplefin_transaction.dig("id")
  
        # If this transaction hasn't been synced yet, create a new transaction in Maybe
        unless transactions_in_maybe.any? { |t| t["plaid_id"] == transaction_id }

          if maybe_account.accountable_type == "Investment" # Investment
            description = simplefin_transaction.dig("description")
            if description.match?(/(CONTRIBUTIONS|INTEREST PAYMENT|AUTO CLEARING HOUSE FUND)/i) && simplefin_transaction.dig("amount").to_f > 0  #todo: make these regex settings
              logger.tagged("SyncLinkageJob") { logger.info "[#{linkage.id}] Adding transaction with plaid_id='#{transaction_id}'"}
              maybe_client.new_transaction(maybe_account.identifier, simplefin_transaction, simplefin_account.currency)
            elsif description.match?(/(RECORDKEEPING|MANAGEMENT|WRAP) FEE/i) && simplefin_transaction.dig("amount").to_f < 0  #todo: make these regex settings
              logger.tagged("SyncLinkageJob") { logger.info "[#{linkage.id}] Adding transaction with plaid_id='#{transaction_id}'"}
              maybe_client.new_transaction(maybe_account.identifier, simplefin_transaction, simplefin_account.currency)
            end
          else # CreditCard,Despository,Loan
            logger.tagged("SyncLinkageJob") { logger.info "[#{linkage.id}] Adding transaction with plaid_id='#{transaction_id}'"}
            maybe_client.new_transaction(maybe_account.identifier, simplefin_transaction, simplefin_account.currency)
          end
        end
      end
      if maybe_account.accountable_type == "Investment" # Investment
        logger.tagged("SyncLinkageJob") { logger.info "[#{linkage.id}] Updating Balance for '#{Time.at(simplefin_account_with_balance.dig("balance-date")).strftime("%m/%d/%Y")}'"}
        maybe_client.upsert_account_valuation(maybe_account.identifier, simplefin_account_with_balance)
      end
    else
      Rails.logger.error("Failed to fetch transactions from SimpleFin API")
      logger.tagged("SyncLinkageJob") { logger.error "[#{linkage.id}] Failed to retrieve data from SimpleFIN"}
      logger.tagged("SyncLinkageJob") { logger.info "[#{linkage.id}] Setting Linkage Status to 'Error'"}
      linkage.update(sync_status: :error, last_sync: Time.current)
    end
    logger.tagged("SyncLinkageJob") { logger.info "[#{linkage.id}] Setting Linkage Status to 'Complete'"}
    linkage.update(sync_status: :complete, last_sync: Time.current)
    maybe_client.close
  end
end
  