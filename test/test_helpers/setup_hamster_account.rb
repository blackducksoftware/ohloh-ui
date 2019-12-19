# frozen_string_literal: true

module SetupHamsterAccount
  def create_hamster_account
    account = Account.where(login: 'ohloh_slave').first
    account ||= create_new_account
    account&.update_attribute(:level, 10)
  end

  private

  def create_new_account
    Account.create(login: 'ohloh_slave', name: 'hamster', email: 'slave@ohloh.net', password: 'password',
                   activated_at: Time.current.utc,
                   github_verification_attributes: { unique_id: Faker::Name.first_name })
  end
end
