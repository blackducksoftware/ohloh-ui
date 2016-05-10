interceptor = Rails.configuration.try(:mail_interceptor)

if Rails.env.staging? && interceptor
  require "#{Rails.root}/lib/mail_interceptors/#{interceptor.underscore}"
  ActionMailer::Base.register_interceptor(interceptor.safe_constantize)
end
