source 'https://rubygems.org'
source 'http://oh-stage-utility-1.blackducksoftware.com:9292'

gem 'activeadmin', git: 'https://github.com/gregbell/active_admin.git'
gem 'airbrake'
gem 'aws-sdk', '< 2.0' # paperclip doesn't work with the new aws-sdk gem
gem 'bluecloth'
gem 'brakeman'
gem 'bundler-audit', git: 'https://github.com/BoboFraggins/bundler-audit'
gem 'coffee-rails'
gem 'coffee-script-source', '~>1.8.0'
gem 'doorkeeper'
gem 'dotenv-rails'
gem 'execjs'
gem 'font-awesome-rails'
gem 'haml-rails'
gem 'jbuilder'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'mini_magick', '~> 4.1.1'
gem 'oh_delegator'
gem 'ohloh_scm'
gem 'open4'
gem 'paperclip'
gem 'pg'
gem 'rails', '~> 4.2.5.1'
gem 'rails-html-sanitizer'
gem 'recaptcha', require: 'recaptcha/rails'
gem 'redis-rails'
gem 'rubocop'
gem 'sass-rails'
gem 'therubyracer'
gem 'twitter-bootstrap-rails'
gem 'uglifier', '>= 2.7.2'
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'sprockets-rails', '~> 2.3.3'
gem 'feedjira'
gem 'whenever', require: false
gem 'ledermann-rails-settings'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', '~> 0.7.2'
  gem 'capistrano'
  gem 'capistrano-faster-assets'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'meta_request'
  gem 'whenever', require: false
end

group :test do
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'flog'
  gem 'haml_lint', '~> 0.13.0'
  gem 'minitest-rails'
  gem 'mocha'
  gem 'ruby_parser'
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem 'spring'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end

group :development, :test do
  gem 'byebug'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'rb-readline'
  gem 'rails-erd'
  gem 'jasmine-rails'
  gem 'jasmine-jquery-rails'
  gem 'teaspoon-jasmine'
end

group :production do
  gem 'airbrake'
  gem 'traceview'
end

group :development, :staging do
  gem 'letter_opener'
  gem 'letter_opener_web', '~> 1.2.0'
end
