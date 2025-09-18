# frozen_string_literal: true

module AccountFind
  module_function

  def by_id_or_login(value)
    Account.find_by('id = :id or lower(login) = :login', id: value.to_i, login: value.downcase)
  end
end
