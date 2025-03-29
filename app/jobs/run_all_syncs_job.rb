require 'net/http'

class RunAllSyncsJob < ApplicationJob
  queue_as :default

  def perform
    url = URI.parse("#{Rails.application.credentials[:api_base_url]}/run_all_syncs")
    Net::HTTP.post(url, {}.to_json, "Content-Type" => "application/json")
  end
end
