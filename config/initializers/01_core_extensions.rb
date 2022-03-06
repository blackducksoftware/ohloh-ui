# frozen_string_literal: true

Dir[Rails.root.join('app', 'core_extensions', '**', '*.rb')].sort.each { |file| require file }
