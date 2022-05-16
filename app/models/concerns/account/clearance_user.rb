# frozen_string_literal: true

module Account::ClearanceUser
  extend ActiveSupport::Concern

  included do
    include Clearance::User

    def email_optional?
      true
    end

    def maintenance
      logout_users
    end

    private

    def logout_users
      Account.logged_in.find_each(&:reset_remember_token!)
    end
  end
end
