# frozen_string_literal: true

source 'https://rubygems.org'
gem 'activeadmin'
gem 'airbrake'
gem 'aws-sdk', '~> 2.3'
gem 'bcrypt_pbkdf', '~> 1.0'
gem 'bootstrap_jt', '~> 0.1.0'
gem 'brakeman', '>= 4.7.1'
gem 'bundler-audit'
gem 'bunny'
gem 'clearance'
gem 'coffee-rails'
gem 'coffee-script-source', '~>1.8.0'
gem 'doorkeeper', '~> 5.2'
gem 'dotenv-rails', '~> 2.8.1'
gem 'feedjira'
gem 'font-awesome-rails'
gem 'haml-rails', '~> 2.0'
gem 'jbuilder'
gem 'jmespath', '~> 1.6.1'
gem 'jwt'
gem 'mini_magick', '~> 4.9.4'
gem 'nokogiri', '~> 1.18.8'
gem 'oh_delegator'
gem 'open4'
gem 'paperclip', '~> 5.3'
gem 'pg', '~> 1.5.9'
gem 'puma'
gem 'rack', '~> 2.2.13'
gem 'rails', '~> 6.1', '>= 6.1.7.10'
gem 'rails-html-sanitizer', '~> 1.4.3'
gem 'ransack', '~> 3.2.1'
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
gem 'tzinfo', '~> 2.0'
gem 'uglifier', '>= 2.7.2'
gem 'will_paginate'
gem 'will_paginate-bootstrap'

group :development do
  gem 'better_errors'
  gem 'bootsnap', require: false
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
