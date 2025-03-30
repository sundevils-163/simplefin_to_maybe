require 'net/http'

class RunAllSyncsJob < ApplicationJob
  queue_as :default

  def perform
    url = URI.parse(Rails.application.routes.url_helpers.run_all_syncs_url)
    Net::HTTP.post(url, {}.to_json, "Content-Type" => "application/json")
  end
end
