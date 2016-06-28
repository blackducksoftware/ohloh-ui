module ScmValidation
  extend ActiveSupport::Concern

  included do
    validate :scm_attributes_and_server_connection, unless: :bypass_url_validation

    private

    def scm_attributes_and_server_connection
      normalize_scm_attributes
      source_scm.validate
      Timeout.timeout(timeout_interval) { source_scm.validate_server_connection }
    rescue Timeout::Error
      source_scm.errors << [:url, I18n.t('repositories.timeout')]
    ensure
      populate_scm_errors
    end

    def normalize_scm_attributes
      source_scm.normalize

      self.url         = source_scm.url
      self.username    = source_scm.username
      self.password    = source_scm.password
    end

    def populate_scm_errors
      source_scm.errors.each do |attribute, error_message|
        if %i(url username password).include?(attribute)
          errors.add(attribute, error_message)
        end
      end
    end

    def timeout_interval
      ENV['SCM_URL_VALIDATION_TIMEOUT'].to_i
    end
  end
end
