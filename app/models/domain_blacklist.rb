class DomainBlacklist < ActiveRecord::Base
  validates :domain, uniqueness: { case_sensitive: false }

  class << self
    def email_banned?(email_address)
      contains?(email_address.split('@').last)
    end

    def contains?(domain)
      exists?(['lower(domain) LIKE ?', "%#{domain.downcase}%"])
    end
  end
end
