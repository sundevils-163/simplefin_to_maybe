require 'net/http'

class RunAllSyncsJob < ApplicationJob
  include CronScheduler  #app/lib/cron_scheduler.rb

  queue_as :default

  include Rails.application.routes.url_helpers  # Include the URL helpers module

  def perform(dont_schedule_followup = false)

    # Make the HTTP request
    uri = URI.parse('http://localhost:3000/linkages/run_all_syncs')

    Net::HTTP.post(uri, {}.to_json, "Content-Type" => "application/json")

    # Schedule the next sync
    update_cron_schedule unless dont_schedule_followup
  end
end
