set :environment, 'production'
set :output, error: 'cron_error.log', standard: 'cron.log'
every 2.weeks, at: '11.00 am', roles: [:utility] do
  rake 'check_broken_links'
end

every 1.day, at: '04.00 am', roles: [:utility] do
  rake 'home_page_stats'
end
