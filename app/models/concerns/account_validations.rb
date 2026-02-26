# frozen_string_literal: true

module AccountValidations
  extend ActiveSupport::Concern

  included do
    validates :email, presence: true, length: { in: 3..100 }, uniqueness: { case_sensitive: false },
                      email_format: true, allow_blank: false

    validates :password, length: { in: 5..40 }, unless: :skip_password_validation?

    validate :valid_current_password?, on: :update, if: :validate_current_password

    validates :url, length: { maximum: 100 }, url_format: true, allow_blank: true
    validates :login, presence: true
    validates :login, length: { in: 3..40 }, uniqueness: { case_sensitive: false },
                      allow_blank: false, default_param_format: true, if: :will_save_change_to_login?
    validates :twitter_account, length: { maximum: 15 }, allow_blank: true
    validates :name, length: { maximum: 50 }, allow_blank: true, format: { without: Patterns::BAD_NAME }

    validate :url_not_blocked_domain
    validate :about_raw_not_blocked_domain
  end

  private

  def blocked_domain_patterns
    Setting.get_value('blocked_domains').to_s.split('|').compact_blank
  end

  def matches_blocked_domain?(value)
    return false if value.blank?

    blocked_domain_patterns.any? do |pattern|
      value.match?(/\b#{Regexp.escape(pattern)}\b/i)
    end
  end

  def url_not_blocked_domain
    errors.add(:url, I18n.t('accounts.edit.blocked_domain_error')) if matches_blocked_domain?(url)
  end

  def about_raw_not_blocked_domain
    raw = about_raw || markup&.raw
    errors.add(:'markup.raw', I18n.t('accounts.edit.blocked_domain_error')) if matches_blocked_domain?(raw)
  end

  def valid_current_password?
    return false if current_password_matches_existing? && access.active_and_not_disabled?

    errors.add(:current_password)
  end

  # Use _was since encrypted_password & salt have already changed in password=.
  def current_password_matches_existing?
    encrypted_password_was == encrypt(current_password, salt_was)
  end
end
