# app/jobs/mortgage_transaction_job.rb
require 'bigdecimal'
require 'bigdecimal/util'
require 'securerandom'

class MortgageTransactionJob < ApplicationJob

  queue_as :default

  def perform(mortgage)

    unless mortgage.day_of_month.to_f == Time.now.day
      log(mortgage, "It's not time to run yet!")
      return
    end

    maybe_account = Account.find_by(id: mortgage.maybe_account_id)

    unless maybe_account
      log(mortgage, "Missing account", :error)
      return
    end

    log(mortgage, "Maybe Account: '#{maybe_account.display_name}' [#{maybe_account.identifier}]; Type: #{maybe_account.accountable_type}")

    maybe_client = MaybeClientService.connect
    unless maybe_client
      log(mortgage, "Failed to connect to Maybe PostgreSQL", :error)
      return
    end

    current_balance = maybe_client.get_account_by_id(maybe_account.identifier).dig("balance").to_d
    log(mortgage, "Current Balance: #{current_balance}")
    log(mortgage, "APR: #{mortgage.apr.to_d}")
    interest_due = current_balance * (mortgage.apr.to_d / 100 / 12)
    currency = maybe_account.currency || "USD"
    
    interest_tx_name = "Interest Payment Offset"
    escrow_tx_name = "Escrow Payment Offset"
    one_time = (mortgage.exclude == true)

    unless maybe_client.entry_exists?(maybe_account.identifier, Time.now.to_i, maybe_client.transaction_key, interest_tx_name)
      log(mortgage, "Adding transaction '#{interest_tx_name}' of #{interest_due}")
      maybe_client.new_transaction(maybe_account.identifier, (interest_due * -1), Time.now.to_i, interest_tx_name, SecureRandom.uuid, currency, one_time)
    end
    
    unless 0 == mortgage.escrow_payment.to_d || maybe_client.entry_exists?(maybe_account.identifier, Time.now.to_i, maybe_client.transaction_key, escrow_tx_name)
      log(mortgage, "Adding transaction '#{escrow_tx_name}' of #{mortgage.escrow_payment}")
      maybe_client.new_transaction(maybe_account.identifier, (mortgage.escrow_payment.to_d * -1), Time.now.to_i, escrow_tx_name, SecureRandom.uuid, currency, one_time)
    end
  end

  private

  def log(mortgage, message, level = :info)
    Rails.logger.public_send(level, "[#{mortgage.id}] #{message}")
  end
end
