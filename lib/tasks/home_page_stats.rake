# frozen_string_literal: true

desc 'Updates the required Home Page stats'
task home_page_stats: :environment do
  Rails.logger.info('Running home_page_stats task')
  contributors = Account.recently_active.includes(best_account_analysis: [:name_fact])
  accounts_ids = []
  contributors.each { |c| accounts_ids << c.id }
  accounts = Account.where(id: accounts_ids).index_by(&:id).values_at(*accounts_ids)
  Rails.cache.write('HomeDecorator-recently_active_accounts-cache', accounts)

  Rails.logger.info('caching vita count')
  account_analysis_count = contributors.map { |c| c.best_account_analysis&.name_fact&.thirty_day_commits }
  Rails.cache.write('HomeDecorator-vita_count-cache', account_analysis_count)

  write_most_active_cache
  write_person_count_cache
  write_active_project_count_cache
  clear_front_page_lists_cache
end

def write_most_active_cache
  Rails.logger.info('caching most active projects')
  ids = Project.most_active.includes(:logo, best_analysis: %i[main_language thirty_day_summary]).pluck(:id)
  Rails.cache.write('HomeDecorator-most_active_projects-cache', ids)
end

def write_person_count_cache
  Rails.logger.info('caching person count')
  Rails.cache.write('HomeDecorator-person_count-cache', Person.count)
end

def write_active_project_count_cache
  Rails.logger.info('caching active_project_count')
  Rails.cache.write('HomeDecorator-active_project_count-cache', Project.active.count)
end

def clear_front_page_lists_cache
  Rails.cache.delete('homepage_top_lists')
end
