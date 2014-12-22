class Account::Authenticator
  def initialize(login:, password:)
    @account = Account.fetch_by_login_or_email(login)
    @password = password
  end

  def authenticated?
    @account.present? && @account.crypted_password == Account::Authenticator.encrypt(@password, @account.salt)
  end

  def account
    @account if authenticated?
  end

  class << self
    def encrypt(key1, key2)
      Digest::SHA1.hexdigest("--#{key2}--#{key1}--")
    end

    def remember(account)
      expires_at = 2.weeks.from_now.utc
      token = Account::Authenticator.encrypt("#{account.email}--#{expires_at}", account.salt)
      account.update_attributes(remember_token_expires_at: expires_at, remember_token: token)
    end

    def forget(account)
      account.update_attributes(remember_token_expires_at: nil, remember_token: nil)
    end
  end
end
