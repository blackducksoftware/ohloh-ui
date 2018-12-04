desc 'Updates the required Home Page stats'
task home_page_stats: :environment do
  data = Account.recently_active.includes(best_vita: [:name_fact])
  Rails.cache.write('HomeDecorator-recently_active_accounts-cache', data)
end
