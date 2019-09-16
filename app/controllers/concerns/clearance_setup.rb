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

    private

    def sign_in_url
      new_session_path
    end
  end
end
