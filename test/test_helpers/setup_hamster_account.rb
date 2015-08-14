module SetupHamsterAccount
  def create_hamster_account
    account = Account.where(login: 'ohloh_slave').first
    account || create_new_account
  end

  private

  def create_new_account
    Account.create(login: 'ohloh_slave', name: 'hamster', password: 'password', password_confirmation: 'password',
                   email: 'slave@ohloh.net', email_confirmation: 'slave@ohloh.net')
  end
end
