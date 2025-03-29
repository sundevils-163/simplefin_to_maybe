# app/services/maybe_client_service.rb

class MaybeClientService
  def self.connect
    Rails.logger.info "Authenticating to Maybe PostgreSQL"
    
    host = Setting.find_by(key: 'maybe_postgres_host')&.value || "127.0.0.1"
    port = Setting.find_by(key: 'maybe_postgres_port')&.value || "5432"
    dbname = Setting.find_by(key: 'maybe_postgres_db')&.value || "maybe"
    user = Setting.find_by(key: 'maybe_postgres_user')&.value || "maybe"
    password = Setting.find_by(key: 'maybe_postgres_password')&.value || "maybe"

    maybe_client = MaybeClient.new(host, port, dbname, user, password)
    
    if maybe_client.connected?
      return maybe_client
    else
      nil
    end
  end
end
  