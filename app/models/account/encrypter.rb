# frozen_string_literal: true

class Account::Encrypter
  def before_validation(account)
    return if account.id? || account.activated_at?

    assign_activation_code_to_random_hash(account)
  end

  def before_save(account)
    encrypt_email(account) if account.email_changed?
  end

  private

  def assign_activation_code_to_random_hash(account)
    account.activation_code = SecureRandom.hex(20)
  end

  def encrypt_email(account)
    account.email_md5 = Digest::MD5.hexdigest(account.email.downcase).to_s
  end
end
