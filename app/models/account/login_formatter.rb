class Account
  class LoginFormatter
    attr_reader :login

    def initialize(login)
      @login = login
    end

    def sanitized_and_unique
      get_unique_login(sanitized_login)
    end

    private

    def sanitized_login
      return login unless login =~ /\A\d.+\Z/
      ('a'..'z').to_a.sample(3).join('') + login
    end

    def get_unique_login(clean_login)
      login = clean_login
      while Account.resolve_login(login).present? || login.length < 3
        login = clean_login + Random.rand(999).to_s
      end
      login
    end
  end
end
