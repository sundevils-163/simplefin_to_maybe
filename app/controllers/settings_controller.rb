# app/controllers/settings_controller.rb
require 'net/http'
require 'uri'
require Rails.root.join("app/lib/simplefin_client.rb")

class SettingsController < ApplicationController
  # Display all settings
  def index
    @settings = Setting.all
  end

  # Edit individual setting
  def edit
    @setting = Setting.find(params[:id])
  end

  # Update setting in the database
  def update
    @setting = Setting.find(params[:id])
    if @setting.update(setting_params)
      redirect_to settings_path, notice: 'Setting was successfully updated.'
    else
      render :edit
    end
  end

  def test_simplefin
    Rails.logger.info "Begin test_simplefin"
    username = Setting.find_by(key: 'simplefin_username')&.value
    password = Setting.find_by(key: 'simplefin_password')&.value

    if username.nil? || password.nil?
      Rails.logger.warn "Missing SimpleFIN username or password!"
      @sf_test = "Username or password not set."
    else
      simplefin_client = SimplefinClient.new(username, password)
      Rails.logger.info "Starting SimpleFIN retrieval of /accounts"
      response = simplefin_client.get_accounts()
      Rails.logger.info "SimpleFIN responded"
  
      if response.is_a?(String)
        Rails.logger.error "Failure in SimpleFIN response: #{response}"
        render plain: "Failed: #{response}"
      elsif response.is_a?(Hash) && response.dig("accounts")
        Rails.logger.info "SimpleFIN request successful"
        result = ["Success"]
        # Capture warnings
        response.dig("errors")&.each do |warning|
          result << " - #{warning}"
        end
        render plain: result.join("\n") # Store the result properly formatted for HTML
      else
        Rails.logger.error "Unknown error with SimpleFIN response"
        render plain: "Unknown Error"
      end
    end
  end  

  private

  # Strong parameters for updating setting
  def setting_params
    params.require(:setting).permit(:key, :value)
  end
end
