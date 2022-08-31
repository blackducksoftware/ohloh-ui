# frozen_string_literal: true

source 'https://rubygems.org'
gem 'activeadmin'
gem 'airbrake', '~> 5.5'
gem 'aws-sdk', '~> 2.3'
gem 'bcrypt_pbkdf', '~> 1.0'
gem 'bootstrap_jt', '~> 0.1.0'
gem 'brakeman', '>= 4.7.1'
gem 'bundler-audit'
gem 'bunny'
gem 'clearance'
gem 'coffee-rails'
gem 'coffee-script-source', '~>1.8.0'
gem 'datadog_api_client'
gem 'doorkeeper', '~> 4.4.0'
gem 'dotenv-rails'
gem 'feedjira'
gem 'font-awesome-rails'
gem 'haml-rails', '~> 1.0'
gem 'jbuilder'
gem 'jmespath', '~> 1.6.1'
gem 'jwt'
gem 'mini_magick', '~> 4.9.4'
gem 'nokogiri', '~> 1.13.8'
gem 'oh_delegator'
gem 'open4'
gem 'paperclip', '~> 5.3'
gem 'pg', '0.20'
gem 'rack', '~> 2.2.3.1'
gem 'rails', '~> 5.2.8'
gem 'rails-html-sanitizer', '~> 1.4.3'
gem 'ransack', github: 'activerecord-hackery/ransack'
gem 'rbnacl', '~>3.2'
gem 'rbnacl-libsodium'
gem 'recaptcha', require: 'recaptcha/rails'
gem 'redcarpet'
gem 'redis-rails', '>= 5.0.2'
gem 'sass-rails'
gem 'sidekiq'
gem 'simplemde-rails'
gem 'sprockets'
gem 'sprockets-rails'
gem 'sql_tracker'
gem 'statsd-instrument'
gem 'thor'
gem 'twitter-bootstrap-rails', '~> 3.2'
gem 'tzinfo', '~> 1.2.10'
gem 'uglifier', '>= 2.7.2'
gem 'whenever', require: false
gem 'will_paginate'
gem 'will_paginate-bootstrap'

group :development do
  gem 'better_errors'
  gem 'bootsnap', '~> 1.10.3', require: false
  gem 'capistrano'
  gem 'capistrano-faster-assets'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv', '~> 2.0'
  gem 'capistrano-sidekiq'
  gem 'ed25519'
end

group :test do
  gem 'haml_lint', '~> 0.21'
  gem 'minitest-rails'
  gem 'minitest-spec-rails'
  gem 'mocha'
  gem 'rails-controller-testing'
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end

group :development, :test do
  gem 'byebug'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rubocop-minitest'
  gem 'rubocop-rails'
end

group :production, :staging do
  gem 'activerecord-nulldb-adapter', require: false
  gem 'ddtrace', require: 'ddtrace/auto_instrument'
end

group :development, :staging do
  gem 'letter_opener'
  gem 'letter_opener_web'
end
