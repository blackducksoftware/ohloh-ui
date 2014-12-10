class Authenticator
  attr_reader :account

  def initialize(login:, password:)
    accounts = Account.arel_table
    @account = Account.where(accounts[:email].eq(login).or(accounts[:login].eq(login))).first
    @password_hash = account ? Authenticator.hashify(string: password, salt: account.salt) : nil
  end

  def correct_password?
    account.present? && @password_hash && (account.crypted_password == @password_hash)
  end

  class << self
    def hashify(string:, salt:)
      Digest::SHA1.hexdigest("--#{salt}--#{string}--")
    end

    def generate_salt
      seed = (0...12).map { (65 + rand(26)).chr }.join
      Digest::SHA1.hexdigest("--#{Time.now}--#{seed}--")
    end
  end
end
