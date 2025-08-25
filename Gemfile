# frozen_string_literal: true

source 'https://rubygems.org'
gem 'activeadmin'
gem 'airbrake', '~> 10.0.3'
gem 'aws-sdk', '~> 3'
gem 'bcrypt_pbkdf', '~> 1.0'
gem 'bootstrap_jt', '~> 0.1.0'
gem 'brakeman', '>= 4.7.1'
gem 'bundler-audit'
gem 'bunny'
gem 'clearance'
gem 'coffee-rails'
gem 'coffee-script-source', '~>1.8.0'
gem 'doorkeeper', '~> 5.5'
gem 'dotenv-rails'
gem 'feedjira'
gem 'font-awesome-rails'
gem 'haml-rails', '~> 2.0'
gem 'jbuilder'
gem 'jmespath', '~> 1.6.1'
gem 'jwt'
gem 'kt-paperclip', '~> 7.0'
gem 'listen'
gem 'mini_magick', '~> 5.2'
gem 'nokogiri'
gem 'open4'
gem 'pg'
gem 'puma'
gem 'rack', '~> 2.2.13'
gem 'rails', '~> 6.1.7.10'
gem 'rails-html-sanitizer', '~> 1.4.3'
gem 'ransack'
gem 'rbnacl', '~>3.2'
gem 'rbnacl-libsodium'
gem 'recaptcha', require: 'recaptcha/rails'
gem 'redcarpet'
gem 'redis-rails', '>= 5.0.2'
gem 'sass-rails'
gem 'sidekiq', '~> 6.5.12'
gem 'simplemde-rails'
gem 'sprockets'
gem 'sprockets-rails'
gem 'sql_tracker'
gem 'statsd-instrument'
gem 'thor'
gem 'twitter-bootstrap-rails', '~> 3.2'
gem 'tzinfo'
gem 'uglifier', '>= 2.7.2'
gem 'webrick'
gem 'will_paginate'
gem 'will_paginate-bootstrap'

group :development do
  gem 'better_errors'
  gem 'bootsnap', '~> 1.10.3', require: false
end

group :test do
  gem 'haml_lint', '~> 0.21'
  gem 'minitest-rails'
  # gem 'minitest-spec-rails', '~> 6.0'
  gem 'mocha'
  gem 'rails-controller-testing'
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end

group :development, :test do
  gem 'bunny-mock'
  gem 'byebug'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rubocop-minitest'
  gem 'rubocop-rails'
end

group :production, :staging do
  gem 'activerecord-nulldb-adapter', require: false
  gem 'datadog', '~> 2.2'
end

group :development, :staging do
  gem 'letter_opener'
  gem 'letter_opener_web'
end
