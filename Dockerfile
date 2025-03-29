# Use an official Ruby image
FROM ruby:3.3.7

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs npm postgresql-client yarn

# Set working directory
WORKDIR /app

# Install bundler
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the entire project
COPY . .

# Precompile assets and run database migrations
RUN bundle exec rake assets:precompile
RUN bundle exec rake db:migrate

# Expose port 3000 for the Rails app
EXPOSE 3000

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
