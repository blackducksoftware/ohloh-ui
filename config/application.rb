require File.expand_path('../boot', __FILE__)
require 'rails/all'

Bundler.require(*Rails.groups)

module OhlohUi
  class Application < Rails::Application
    config.generators.stylesheets = false
    config.generators.javascripts = false
    config.generators.helper = false
    config.action_controller.include_all_helpers = false
  end
end
