class DatabaseController < ApplicationController

  def reset
    Rails.logger.info "Resetting database..."

    Rails.application.load_tasks
    
    ActiveRecord::Base.connection.transaction do
      tables = ActiveRecord::Base.connection.tables
      tables.each do |table|
        next if table == "schema_migrations" # Do not truncate schema information
        ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table} RESTART IDENTITY CASCADE;")
      end
    end

    Rake::Task['db:seed'].invoke
    
    redirect_to root_path
  end
  
end
  