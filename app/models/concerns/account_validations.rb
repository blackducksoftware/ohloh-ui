module AccountValidations
  extend ActiveSupport::Concern

  included do
    validates :email, presence: :true, length: { in: 3..100 }, uniqueness: { case_sensitive: false },
                      confirmation: true, email_format: true, allow_blank: false
    validates :email_confirmation, email_format: true, presence: true, allow_blank: false, on: :create

    validates :password, presence: true, confirmation: true, on: :create
    validates :password_confirmation, presence: true, on: :create
    validates :password, :password_confirmation, length: { in: 5..40 }

    # validates :password, presence: true, confirmation: true, on: :update #if: :crypted_password_changed?
    # validates :password_confirmation, presence: true, on: :update, if: :crypted_password_changed?
    # validate :valid_current_password?, on: :update #if: :crypted_password_changed?

    validates :password, presence: true, confirmation: true, on: :update, if: :changing_password?
    validates :password_confirmation, presence: true, on: :update, if: :changing_password?
    validate :valid_current_password?, on: :update, if: :changing_password?

    validates :url, length: { maximum: 100 }, url_format: true, allow_blank: true
    validates :login, presence: true
    validates :login, length: { in: 3..40 }, uniqueness: { case_sensitive: false },
                      allow_blank: false, format: { with: Patterns::LOGIN_FORMAT }, if: :login_changed?
    validates :twitter_account, length: { maximum: 15 }, allow_blank: true
    validates :name, length: { maximum: 50 }, allow_blank: true

    def changing_password?
      # binding.pry
      # Maybe use some other attribute besides crypted_password.
      # current_password.present? ? true : false
      current_password.present? || password.present?
    end
  end
end
