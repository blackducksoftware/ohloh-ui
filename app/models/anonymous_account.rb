module AnonymousAccount
  LOGIN = 'anonymous_coward'

  class << self
    def create!
      anonymous_account = Account.new(name: 'Anonymous Coward', login: LOGIN,
                                      email: 'anon@openhub.net', email_confirmation: 'anon@openhub.net',
                                      password: 'mailpass', password_confirmation: 'mailpass')
      anonymous_account.save!
      Account::Authorize.new(anonymous_account).activate!(nil)

      anonymous_account
    end
  end
end
