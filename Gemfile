source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

# Framework
gem 'rails', '~> 6.0.3', '>= 6.0.3.5'

# Database
gem 'pg'

# Use Puma as the app server
gem 'puma', '~> 4.1'

# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
gem 'sprockets', '3.7.2' # to fix issue

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # tests
  gem 'rspec-rails'
  gem 'rswag-specs'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  gem 'annotate'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  # For memory profiling
  gem 'memory_profiler'
  # For call-stack profiling flamegraphs
  gem 'stackprof'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
  # clean DB after tests
  gem 'database_cleaner-active_record'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# ADMIN
gem 'activeadmin'
gem 'draper'
gem 'arctic_admin'

# authentication & permissions
gem 'devise', '~> 4.7.1'
gem 'omniauth-discord'
gem 'cancancan'

# other translations
gem 'rails-i18n'
gem 'devise-i18n'

# JS
gem 'select2-rails'
gem 'toastr-rails'
gem 'leaflet-rails'
gem 'jquery-minicolors-rails'

# Theming
gem 'simple_form'
gem 'bootstrap', '~> 4.5.2'
gem 'bootstrap4-kaminari-views'

# errors tracking
gem 'rollbar'

# global search
gem 'pg_search'

# auditing
gem 'paper_trail'

# ENV
gem 'figaro'

# filters
gem 'has_scope'

# Discord
gem 'discordrb'
gem 'rbnacl-libsodium'

# GraphQL
gem 'graphql-client'

# API doc
gem 'rswag-api'
gem 'rswag-ui'

# Jobs
gem 'sidekiq'
gem 'sidekiq-cron', '~> 1.1'

# AS validations
gem 'active_storage_validations'

# S3
gem 'aws-sdk-s3', require: false

# Markdown
gem 'markdown_views'

# Calendar
gem 'icalendar'

# Twitch
gem 'twitch-api', github: 'mauricew/ruby-twitch-api'

# Geocoding
gem 'geocoder'

group :production do
  # for assets compilation
  gem 'activerecord-nulldb-adapter'
  # Datadog APM
  gem 'ddtrace'
end

# security fixes
gem 'nokogiri', ">= 1.11.0.rc4"

# datadog logs
gem 'lograge'
