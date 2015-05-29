class RecentlyActiveAccountsCache < ActiveRecord::Base
  self.table_name = 'recently_active_accounts_cache'
  self.primary_key = 'id'

  class << self
    def instance
      where(id: 2).first_or_create
    end

    def accounts
      retrieve_accounts_preserving_order(JSON.parse(instance.accounts)) || []
    rescue StandardError
      RecentlyActiveAccountsCache.recalc!
    end

    def recalc!
      recents = Account.recently_active
      instance.update_attribute(:accounts, recents.map(&:id).to_json)
      recents
    end

    private

    def retrieve_accounts_preserving_order(ids)
      Account.includes(best_vita: [:vita_fact]).find(ids).index_by(&:id).slice(*ids).values
    end
  end
end
