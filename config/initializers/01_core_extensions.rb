# frozen_string_literal: true

Dir[Rails.root.join('app', 'core_extensions', '**', '*.rb')].each { |file| require file }
