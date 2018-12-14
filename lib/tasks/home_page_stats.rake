desc 'Updates the required Home Page stats'
task home_page_stats: :environment do
  contributors = Account.recently_active.includes(best_vita: [:name_fact])
  Rails.cache.write('HomeDecorator-recently_active_accounts-cache', contributors)

  vita_count = contributors.map { |c| c.best_vita.name_fact.thirty_day_commits if c.best_vita }
  Rails.cache.write('HomeDecorator-vita_count-cache', vita_count)
end
