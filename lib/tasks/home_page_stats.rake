desc 'Updates the required Home Page stats'
task home_page_stats: :environment do
  contributors = Account.recently_active.includes(best_vita: [:name_fact])
  accounts_ids = []
  contributors.each { |c| accounts_ids << c.id }
  accounts = Account.where(id: accounts_ids).index_by(&:id).values_at(*accounts_ids)
  Rails.cache.write('HomeDecorator-recently_active_accounts-cache', accounts)

  vita_count = contributors.map { |c| c.best_vita.name_fact.thirty_day_commits if c.best_vita }
  Rails.cache.write('HomeDecorator-vita_count-cache', vita_count)
end
