class Account::Access < OhDelegator::Base
  delegate :level, to: :account

  DEFAULT = 0
  BOT = 5
  ADMIN = 10
  DISABLED = -10
  SPAM = -20

  def admin?
    level.eql?(ADMIN)
  end

  def default?
    level.eql?(DEFAULT)
  end

  def bot?
    level.eql?(BOT)
  end

  def activated?
    account.activated_at.present?
  end
  alias email_verified? activated?

  def disabled?
    level.to_i < DEFAULT
  end

  def active_and_not_disabled?
    activated? && !disabled?
  end

  def spam?
    level.eql?(SPAM)
  end

  def activate!(activation_code)
    return unless !activated? && activation_code.eql?(account.activation_code)
    account.update_attributes!(activated_at: Time.current, activation_code: nil)
    AccountMailer.activation(account).deliver_now
  end

  def disable!
    account.update_attributes!(level: DISABLED)
  end

  def spam!
    Account.transaction do
      account.update_attribute(:level, SPAM)
    end
  end

  def bot!
    account.update_attributes!(level: BOT)
  end

  def mobile_or_oauth_verified?
    return if account.nil?
    account.verifications.exists?
  end

  def verified?
    mobile_or_oauth_verified? && email_verified?
  end

  def verify_existing_github_user(github_api)
    update_github_verification(github_api)
    account.update_attributes!(activated_at: Time.current, activation_code: nil) unless activated?
  end

  private

  def update_github_verification(github_api)
    if account.github_verification
      account.github_verification.update!(token: github_api.access_token)
    else
      account.create_github_verification!(token: github_api.access_token, unique_id: github_api.login)
    end
  end
end
