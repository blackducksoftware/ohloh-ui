# frozen_string_literal: true

module ClearanceSetup
  extend ActiveSupport::Concern

  included do
    include Clearance::Controller

    def authenticate(params)
      account = Account.fetch_by_login_or_email(params[:login][:login])
      return unless account
      return account if account.authenticated?(params[:login][:password])
    end

    def current_user
      super || NilAccount.new
    end

    def expired_token?
      return false unless current_user&.last_seen_at && current_user.last_seen_at < expiration_days.days.ago

      current_user.reset_remember_token!
      request.env[:clearance].sign_out
      true
    end

    def expiration_days
      ENV['EXPRIATION_DAYS'] ? ENV['EXPRIATION_DAYS'].to_i : 21  # default to 3 weeks
    end

    private

    def sign_in_url
      new_session_path
    end
  end
end
