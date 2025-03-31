# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb


Setting.find_or_create_by(key: 'simplefin_username') do |setting|
    setting.display_name = 'SimpleFIN Username'
    setting.value = nil
end

Setting.find_or_create_by(key: 'simplefin_password') do |setting|
    setting.display_name = 'SimpleFIN Password'
    setting.value = nil
end

Setting.find_or_create_by(key: 'maybe_postgres_host') do |setting|
    setting.display_name = 'Maybe PostgreSQL Host'
    setting.value = nil
end

Setting.find_or_create_by(key: 'maybe_postgres_port') do |setting|
    setting.display_name = 'Maybe PostgreSQL Port'
    setting.value = nil
end

Setting.find_or_create_by(key: 'maybe_postgres_db') do |setting|
    setting.display_name = 'Maybe PostgreSQL Database'
    setting.value = nil
end

Setting.find_or_create_by(key: 'maybe_postgres_user') do |setting|
    setting.display_name = 'Maybe PostgreSQL User'
    setting.value = nil
end

Setting.find_or_create_by(key: 'maybe_postgres_password') do |setting|
    setting.display_name = 'Maybe PostgreSQL Password'
    setting.value = nil
end

Setting.find_or_create_by(key: 'lookback_days') do |setting|
    setting.display_name = 'Lookback Days'
    setting.value = nil
end

Setting.find_or_create_by(key: 'synchronization_schedule') do |setting|
    setting.display_name = 'Sync Schedule'
    setting.value = nil
end
