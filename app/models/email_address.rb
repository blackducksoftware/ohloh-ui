# frozen_string_literal: true

class EmailAddress < ApplicationRecord
  BLACKLISTED_EMAILS = ['root@localhost'].freeze
  include EmailObfuscation

  class << self
    def search_sql(address_string)
      conditions = ['address IN (?)', address_string.split - BLACKLISTED_EMAILS]

      %[SELECT array_agg(id) AS ids
      FROM email_addresses
      WHERE #{sanitize_sql_array(conditions)}]
    end
  end
end
