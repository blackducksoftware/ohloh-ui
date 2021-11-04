# frozen_string_literal: true

return unless Rails.env.production? || Rails.env.staging?

Datadog.configure do |c|
  c.use :rails
end
