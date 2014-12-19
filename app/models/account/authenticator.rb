class Account::Authenticator
  def initialize(login:, password:)
    @account = Account.fetch_by_login_or_email(login)
    @password = password
  end

  def authenticate?(password)
    @account.crypted_password == Account::Authenticator.encrypt(password, @account.salt)
  end

  def authenticate!
    @account if @account && @account.authorization.active_and_not_disabled? && authenticate?(@password)
  end

  class << self
    def encrypt(key1, key2)
      Digest::SHA1.hexdigest("--#{key1}--#{key2}--")
    end

    def remember(account)
      expires_at = 2.weeks.from_now.utc
      token = Account::Authenticator.encrypt("#{email}--#{expires_at}", salt)
      account.update_attributes(remember_token_expires_at: expires_at, remember_token: token)
    end

    def forget(account)
      account.update_attributes(remember_token_expires_at: nil, remember_token: nil)
    end
  end
end
