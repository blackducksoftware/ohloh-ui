module AccountValidations
  extend ActiveSupport::Concern

  included do
    validates :email, presence: :true, length: { in: 3..100 }, uniqueness: { case_sensitive: false },
                      confirmation: true, email_format: true, allow_blank: false
    validates :email_confirmation, email_format: true, presence: true, allow_blank: false, on: :create

    validates :password, length: { in: 5..40 }, confirmation: true, unless: :skip_password_validation?

    validate :valid_current_password?, on: :update, if: :validate_current_password

    validates :url, length: { maximum: 100 }, url_format: true, allow_blank: true
    validates :login, presence: true
    validates :login, length: { in: 3..40 }, uniqueness: { case_sensitive: false },
                      allow_blank: false, default_param_format: true, if: :login_changed?
    validates :twitter_account, length: { maximum: 15 }, allow_blank: true
    validates :name, length: { maximum: 50 }, allow_blank: true
  end

  private

  def valid_current_password?
    return if current_password_matches_existing? && access.active_and_not_disabled?
    errors.add(:current_password)
  end

  # Use _was since encrypted_password & salt have already changed in password=.
  def current_password_matches_existing?
    encrypted_password_was == encrypt(current_password, salt_was)
  end
end
