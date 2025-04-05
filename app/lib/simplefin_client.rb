# app/lib/simplefin_client.rb

require 'json'
require 'net/http'
require 'uri'

class SimplefinClient
  BASE_URL = "https://beta-bridge.simplefin.org/simplefin"  # SimpleFIN API base URL

  def initialize(username, password)
    @username = username
    @password = password
  end

  # Method to fetch all accounts, balances only
  def get_accounts
    query_params = {
      "balances-only" => 1,
      "start-date" => (Time.now + (24 * 60 * 60)).to_i   #future date to avoid grabbing any transactions
    }
    invoke_request("/accounts", query_params)
  end

  # Method to fetch single account, balances only
  def get_account(account_id)
    query_params = {
      "balances-only" => 1,
      "start-date" => (Time.now + (24 * 60 * 60)).to_i,   #future date to avoid grabbing any transactions
      "account" => URI.encode_www_form_component(account_id)
    }
    invoke_request("/accounts", query_params)
  end

  # Method to fetch all transactions for a specific account within a date range
  def get_transactions(account_id, start_date)
    query_params = {
      "start-date" => start_date,
      "account" => URI.encode_www_form_component(account_id)
    }
    invoke_request("/accounts", query_params)
  end

  private

  # Helper method to make HTTP requests with basic authentication
  def invoke_request(endpoint, query_params = {})
    uri = URI.parse("#{BASE_URL}#{endpoint}")
    uri.query = URI.encode_www_form(query_params) unless query_params.empty?

    Rails.logger.info "Invoking HTTP GET on '#{uri}'"

    # Perform HTTP request with basic authentication
    request = Net::HTTP::Get.new(uri)
    request.basic_auth(@username, @password)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    handle_response(response)
  end

  # Handles API responses and errors, returns structured data
  def handle_response(response)
    parsed_body = JSON.parse(response.body) rescue nil

    # Return a structured hash with status code, response body, and success flag
    {
      status_code: response.code.to_i,
      response: parsed_body,
      success: response.code.to_i == 200,
      error_message: parsed_body ? parsed_body["errors"] : nil
    }
  end
end
