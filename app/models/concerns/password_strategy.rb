module PasswordStrategy
  def authenticated?(password)
    encrypted_password == encrypt(password, salt)
  end

  def encrypt(key1, key2)
    Digest::SHA1.hexdigest("--#{key2}--#{key1}--")
  end

  def password=(new_password)
    return unless new_password

    @password = new_password
    self.salt = encrypt(Time.current.to_s, new_password)
    self.encrypted_password = encrypt(new_password, salt)
  end
end
