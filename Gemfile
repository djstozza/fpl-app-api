source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Configure ENV from .env files
# Load this first so ENV is available for other gems
gem 'dotenv-rails', groups: %i[development test]

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.4.3'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Handle users
gem 'devise'

# Decode JSON Web Tokens
gem 'jwt'

# The Database Toolkit for Ruby
gem 'sequel', '~> 5.23'
gem 'sequel_pg', require: false

# Background processing jobs
gem 'sidekiq'
gem 'sidekiq-scheduler'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

# Add decorators for models
gem 'draper'

# Fetch and post http requests
gem 'httparty'

# Allow easy cloning of application record instances, including has_many associations etc
gem 'amoeba'

group :development, :test do
  # Identify inefficient ActiveRecord queries
  gem 'bullet'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  # Use ActiveRecord factories for testing
  gem 'factory_bot_rails'

  # REPL based inspection and debugging
  gem 'pry'

  gem 'responders'

  gem 'faraday-retry'

  # Style and Lint checking
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false

  # Test framework
  gem 'rspec-rails'
end

group :development do
  # Add schema info to models, fixtures etc for ease of reference
  gem 'annotate'

  # Static analysis of code
  gem 'brakeman'

  gem 'listen', '~> 3.2'

  # Better rails console
  gem 'pry-rails'

  # Run static analysis and code style checks on code diff
  gem 'pronto'
  gem 'pronto-brakeman'
  gem 'pronto-rubocop'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :test do
  # Clean database during spec runs
  gem 'database_cleaner'

  # Give us code coverage metrics
  gem 'simplecov', require: false

  # Stub HTTP requests
  gem 'webmock'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
