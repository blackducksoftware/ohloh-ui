class Account::Access
  DEFAULT = 0
  ADMIN = 10
  DISABLED = -10
  SPAM = -20

  def initialize(account)
    @account = account
    @level = @account.try(:level)
  end

  def admin?
    @level.eql?(ADMIN)
  end

  def default?
    @level.eql?(DEFAULT)
  end

  def activated?
    @account.activated_at.present?
  end

  def disabled?
    @level < DEFAULT
  end

  def active_and_not_disabled?
    activated? && !disabled?
  end

  def spam?
    @level.eql?(SPAM)
  end

  def activate!(activation_code)
    return unless !activated? && activation_code.eql?(@account.activation_code)
    @account.update_attributes!(activated_at: Time.now.utc, activation_code: nil)
  end

  def disable!
    @account.update_attributes!(level: DISABLED)
  end

  def spam!
    Account.transaction do
      @account.update_attributes!(level: SPAM)
    end
  end
end
