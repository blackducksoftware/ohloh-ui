module AuthenticationFilter
  extend ActiveSupport::Concern

  included do
    before_action :redirect_invalid_github_account, only: :github_callback, unless: :github_api_account_is_verified?
    before_action :redirect_matching_account, only: :github_callback, unless: -> { current_user.present? }
    before_action :redirect_if_current_user_verified

    private

    def redirect_invalid_github_account
      return if github_api.created_at < 1.month.ago && github_api.repository_has_language?

      redirect_path = current_user.present? ? new_authentication_path : new_account_path
      redirect_to redirect_path, notice: t('.invalid_github_account')
    end

    def github_api
      @github_api ||= GithubApi.new(params[:code])
    end

    def redirect_matching_account
      account = github_api_account
      return unless account

      account.update!(activated_at: Time.current, activation_code: nil) unless account.access.activated?
      verification = build_github_verification
      if verification.save
        sign_in_and_redirect_to(account)
      else
        StatsD.increment('Openhub.Session.github.fail')
        redirect_to new_session_path, notice: t('github_sign_in_failed')
      end
    end

    def github_api_account
      # rubocop:disable Naming/MemoizedInstanceVariableName
      @account ||= Account.find_by(email: github_api.email)
      @account ||= Account.where(email: github_api.secondary_emails).first
      @account ||= GithubVerification.find_by(unique_id: github_api.login).try(:account)
      # rubocop:enable Naming/MemoizedInstanceVariableName
    end

    def build_github_verification
      GithubVerification.find_or_initialize_by(account_id: github_api_account.id).tap do |verification|
        verification.token = github_api.access_token
        verification.unique_id = github_api.login
      end
    end

    def sign_in_and_redirect_to(account)
      StatsD.increment('Openhub.Session.github.success')
      reset_session
      clearance_session.sign_in account

      if github_api && github_api.all_emails.exclude?(account.email)
        flash[:notice] = t('.email_mismatch', settings_account_link: settings_account_path(account))
      end
      redirect_to account
    end

    def github_api_account_is_verified?
      github_api_account && github_api_account.github_verification
    end

    def redirect_if_current_user_verified
      return if current_user.nil?

      redirect_to root_path if current_user.access.mobile_or_oauth_verified?
    end
  end
end
