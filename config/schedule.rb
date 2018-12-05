set :environment, 'production'
every 2.days, at: '11.00 am', roles: [:sidekiq] do
  rake check_broken_links
end

every 1.day, at: '04.00 am', roles: [:sidekiq] do
  rake home_page_stats
end
