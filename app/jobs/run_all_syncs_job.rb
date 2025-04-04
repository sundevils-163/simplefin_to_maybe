require 'net/http'

class RunAllSyncsJob < ApplicationJob
  include CronScheduler  #app/lib/cron_scheduler.rb
  #include JobLogger      #app/lib/job_logger.rb

  queue_as :default

  def perform(dont_schedule_followup = false)

    # Make the HTTP request
    port = ENV['PORT'] || '3000'
    url = "http://localhost:#{port}/linkages/run_all_syncs"
    uri = URI.parse(url)

    Rails.logger.info "POST'ing to #{url}"

    begin
      response = Net::HTTP.post(uri, {}.to_json, { "Content-Type" => "application/json" })
      
      Rails.logger.info "HTTP Response Code: #{response.code}"
      Rails.logger.info "HTTP Response Body: #{response.body}"
    rescue => e
      Rails.logger.error "HTTP Request failed: #{e.message}"
    end

    # Schedule the next sync
    update_cron_schedule unless dont_schedule_followup  #app/lib/cron_scheduler.rb
  end
end
