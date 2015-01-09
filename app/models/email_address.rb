class EmailAddress < ActiveRecord::Base
  BLACKLISTED_EMAILS = ['root@localhost']

  class << self
    def search_sql(address_str)
      conds = ['address IN (?)', address_str.split - BLACKLISTED_EMAILS]
      %[SELECT array_agg(id) AS ids
      FROM email_addresses
      WHERE #{sanitize_sql_array(conds)}]
    end
  end
end
