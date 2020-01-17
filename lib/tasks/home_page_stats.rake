# frozen_string_literal: true

desc 'Updates the required Home Page stats'
task home_page_stats: :environment do
  contributors = Account.recently_active.includes(best_account_analysis: [:name_fact])
  accounts_ids = []
  contributors.each { |c| accounts_ids << c.id }
  accounts = Account.where(id: accounts_ids).index_by(&:id).values_at(*accounts_ids)
  Rails.cache.write('HomeDecorator-recently_active_accounts-cache', accounts)

  account_analysis_count = contributors.map { |c| c.best_account_analysis&.name_fact&.thirty_day_commits }
  Rails.cache.write('HomeDecorator-vita_count-cache', account_analysis_count)
end
