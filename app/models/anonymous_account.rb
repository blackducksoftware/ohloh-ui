# frozen_string_literal: true

module AnonymousAccount
  LOGIN = 'anonymous_coward'

  class << self
    def create!
      anonymous_account = Account.new(name: 'Anonymous Coward', login: LOGIN,
                                      email: 'anon@openhub.net', password: 'mailpass')
      anonymous_account.save!
      anonymous_account.access.activate!(nil)

      anonymous_account
    end
  end
end
