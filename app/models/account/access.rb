class Account::Access < OhDelegator::Base
  delegate :level, to: :account

  DEFAULT = 0
  ADMIN = 10
  DISABLED = -10
  SPAM = -20

  def admin?
    level.eql?(ADMIN)
  end

  def default?
    level.eql?(DEFAULT)
  end

  def activated?
    account.activated_at.present?
  end
  alias_method :email_verified?, :activated?

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

  def mobile_verified?
    account.twitter_id?
  end

  def verified?
    mobile_verified? && email_verified?
  end
end
