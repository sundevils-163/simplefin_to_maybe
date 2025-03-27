#app/lib/simplefin_client.rb

require 'json'
require 'net/http'
require 'uri'

class SimplefinClient
  BASE_URL = "https://beta-bridge.simplefin.org/simplefin"  # SimpleFIN API base URL

  def initialize(username, password)
    @username = username
    @password = password
  end

  # Method to fetch all accounts
  def get_accounts()
    query_params = { "balances-only" => 1 }
    return invoke_request("/accounts", query_params)
  end

  # Method to fetch all transactions for a specific account within a date range
  def get_transactions(account_id, start_date)
    query_params = {
      "start-date" => start_date,
      "account" => URI.encode_www_form_component(account_id)
    }
    response = invoke_request("/accounts", query_params)
    response.dig("accounts", 0, "transactions") || []
  end

  private

  # Helper method to make HTTP requests with basic authentication
  def invoke_request(endpoint, query_params = {})
    uri = URI.parse("#{BASE_URL}#{endpoint}")
    uri.query = URI.encode_www_form(query_params) unless query_params.empty?

    # Perform HTTP request with basic authentication
    request = Net::HTTP::Get.new(uri)
    request.basic_auth(@username, @password)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    handle_response(response)
  end

  # Handles API responses and errors
  def handle_response(response)
    case response.code.to_i
    when 200
      return JSON.parse(response.body)
    else
      raise "Error: #{response.code} - #{response.body}"
    end
  end
end