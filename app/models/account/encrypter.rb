class Account::Encrypter
  def before_validation(account)
    return unless account.new_record?
    assign_activation_code_to_random_hash(account)
    encrypt_salt(account)
  end

  def before_save(account)
    encrypt_email(account) if account.email_changed?
    encrypt_password(account) if account.password.present?
  end

  private

  def assign_activation_code_to_random_hash(account)
    account.activation_code = SecureRandom.hex(20)
  end

  def encrypt_email(account)
    account.email_md5 = Digest::MD5.hexdigest(account.email.downcase).to_s
  end

  def encrypt_salt(account)
    account.salt = Account::Authenticator.encrypt(Time.current.to_s, account.login)
  end

  def encrypt_password(account)
    account.crypted_password = Account::Authenticator.encrypt(account.password, account.salt)
  end
end
