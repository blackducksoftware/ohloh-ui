# frozen_string_literal: true

Rails.root.glob('app/core_extensions/**/*.rb').sort.each { |file| require file }
