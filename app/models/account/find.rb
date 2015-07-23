class Account::Find
  class << self
    def by_id_or_login(value)
      Account.where('id = :id or lower(login) = :login', id: value.to_i, login: value.downcase).first
    end
  end
end
