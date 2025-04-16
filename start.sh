#!/bin/bash
set -e

# Remove any pre-existing server.pid for Rails
rm -f /rails/tmp/pids/server.pid || true

# Create / Migrate the database
bundle exec rails db:prepare

# Init default data
bundle exec rails db:seed

# Start Rails and GoodJob
echo "Starting Rails and GoodJob..."
bundle exec rails server -b 0.0.0.0 -p 3000
bundle exec good_job start --execution-mode=async --enable-cron --max-threads=2

#tail -f /dev/null