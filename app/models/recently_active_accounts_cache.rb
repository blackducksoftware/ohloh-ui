class RecentlyActiveAccountsCache < ActiveRecord::Base
  self.table_name = 'recently_active_accounts_cache'
  self.primary_key = 'id'

  def self.instance
    where(id: 2).first_or_create
  end

  def self.accounts
    Account.find(JSON.parse(instance.accounts)) || []
  rescue StandardError
    RecentlyActiveAccountsCache.recalc!
  end

  def self.recalc!
    recents = Account.recently_active
    instance.update_attribute(:accounts, recents.map(&:id).to_json)
    recents
  end
end
