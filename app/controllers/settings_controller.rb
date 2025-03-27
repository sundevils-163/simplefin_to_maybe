# app/controllers/settings_controller.rb
require 'net/http'
require 'uri'
require Rails.root.join("app/lib/simplefin_client.rb")
require Rails.root.join("app/lib/maybe_client.rb")

class SettingsController < ApplicationController
  before_action :set_setting, only: [:update]

  # Display all settings
  def index
    @settings = Setting.all
  end

  # Update setting in the database
  def update
    if @setting.update(setting_params)
      render json: { success: true, value: @setting.value }
    else
      render json: { success: false, errors: @setting.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def test_simplefin
    Rails.logger.info "Begin test_simplefin"
    username = Setting.find_by(key: 'simplefin_username')&.value
    password = Setting.find_by(key: 'simplefin_password')&.value

    if username.blank? || password.blank?
      Rails.logger.warn "Missing SimpleFIN username or password!"
      render plain: "Username or password not set."
    else
      simplefin_client = SimplefinClient.new(username, password)
      Rails.logger.info "Starting SimpleFIN retrieval of /accounts"
      response = simplefin_client.get_accounts
  
      if response[:success]
        Rails.logger.info "Succesfully retrieved SimpleFIN"
        output = ["\nSuccess!"]
        response[:response].dig("errors")&.each do |warning|
          output << "  Warning: #{warning}"
        end
        render plain: output.join("\n")
        cache_accounts(response[:response].dig("accounts"), "simplefin")
      else
        output = ["\nError during retrieval: [#{response[:status_code]}]"]
        response[:response].dig("errors")&.each do |warning|
          output << "  #{warning}"
        end
        output = output.join(" ")
        Rails.logger.error output
        render plain: output
      end
    end
  end

  def test_maybe
    Rails.logger.info "Begin test_maybe"
    host = Setting.find_by(key: 'maybe_postgres_host')&.value || "127.0.0.1"
    port = Setting.find_by(key: 'maybe_postgres_port')&.value || "5432"
    dbname = Setting.find_by(key: 'maybe_postgres_db')&.value || "maybe"
    user = Setting.find_by(key: 'maybe_postgres_user')&.value || "maybe"
    password = Setting.find_by(key: 'maybe_postgres_password')&.value || "maybe"

    maybe_client = MaybeClient.new(host, port, dbname, user, password)
    if maybe_client.connected?
      render plain: "\nSuccess!"
      accounts = maybe_client.get_accounts()
      cache_accounts(accounts, "maybe")
    else
      render plain: maybe_client.error_message
    end
  end

  private

  def cache_accounts(accounts, account_type)
    accounts.each do |account_data|
      if account_type == "simplefin"
        identifier = account_data.dig("id")
        display_name = "#{account_data.dig("org", "name")} - #{account_data.dig("name")}"
      elsif account_type == "maybe"
        identifier = account_data.dig("id")
        display_name = account_data.dig("name")
        accountable_type = account_data.dig("accountable_type")
      else
        break
      end
      Account.find_or_create_by(account_type: account_type, identifier: identifier) do |account|
        account.display_name = display_name
        account.accountable_type = accountable_type
      end
    end
  end

  def set_setting
    # Find the setting by its key
    @setting = Setting.find_by(key: params[:id])  # Assuming `id` refers to the setting key
    if @setting.nil?
      render json: { success: false, error: 'Setting not found' }, status: :not_found
    end
  end

  # Strong parameters for updating setting
  def setting_params
    params.require(:setting).permit(:key, :value)
  end
end
