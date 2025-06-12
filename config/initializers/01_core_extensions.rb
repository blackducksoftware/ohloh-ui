# frozen_string_literal: true

Rails.root.glob('app/core_extensions/**/*.rb').each { |file| require file }
