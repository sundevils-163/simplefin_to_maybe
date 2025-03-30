#!/bin/bash

# Create / Migrate the database
bundle exec rails db:prepare

# Init default data
bundle exec rails db:seed

# Start Rails and GoodJob
echo "Starting Rails and GoodJob..."
bundle exec rails server -b 0.0.0.0 -p 3000
bundle exec good_job start --enable-cron

#tail -f /dev/null