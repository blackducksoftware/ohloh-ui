class RecentlyActiveAccountsCache < ActiveRecord::Base
  self.table_name = 'recently_active_accounts_cache'
  self.primary_key = 'id'

  serialize :accounts

  def self.instance
    first || new
  end

  def self.accounts
    instance.accounts || []
  end

  def self.recalc!
    instance.update_attribute(:accounts, Account.recently_active)
  end
end
