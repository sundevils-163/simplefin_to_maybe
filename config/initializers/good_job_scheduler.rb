require 'good_job'

Rails.application.config.after_initialize do
  Thread.new do
    loop do
      begin
        cron_expression = Setting.find_by(key: 'synchronization_schedule')&.value || '0 5,23 * * *'
        GoodJob::CronEntry.upsert({ key: 'run_all_syncs', cron: cron_expression, class: 'RunAllSyncsJob' })
      rescue ActiveRecord::ConnectionNotEstablished, NameError => e
        Rails.logger.error "GoodJob Scheduler Error: #{e.message}"
      end
      sleep 60
    end
  end
end
