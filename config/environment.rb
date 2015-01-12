# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# TODO: patch this up when we're getting ready to deploy:
ENV['URL_HOST'] = '0.0.0.0:3000'
