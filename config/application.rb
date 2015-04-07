require File.expand_path('../boot', __FILE__)
require 'rails/all'

Bundler.require(*Rails.groups)

require 'dotenv'
Dotenv.load '.env.local', ".env.#{Rails.env}"

module OhlohUi
  class Application < Rails::Application
    config.generators.stylesheets = false
    config.generators.javascripts = false
    config.generators.helper = false
    config.action_controller.include_all_helpers = false
    config.active_record.schema_format = :sql
    config.active_record.raise_in_transactional_callbacks = true

    config.google_maps_api_key = 'AIzaSyBGY091UPV-hajnLzUVSyp9pUGlWsIibDM'

    config.autoload_paths << "#{Rails.root}/lib"
  end
end
