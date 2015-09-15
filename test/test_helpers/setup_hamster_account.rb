module SetupHamsterAccount
  def create_hamster_account
    account = Account.where(login: 'ohloh_slave').first
    account ||= create_new_account
    account.update_attribute(:level, 10) if account
  end

  private

  def create_new_account
    TwitterDigits.stubs(:get_twitter_id).returns(Faker::Internet.password)
    Account.create(login: 'ohloh_slave', name: 'hamster', password: 'password', password_confirmation: 'password',
                   email: 'slave@ohloh.net', email_confirmation: 'slave@ohloh.net', activated_at: Time.current.utc)
  end
end
