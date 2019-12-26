# frozen_string_literal: true

env :PATH, ENV['PATH']
set :environment, 'production'
set :output, error: 'cron_error.log', standard: 'cron.log'
every 2.weeks, at: '11.00 am', roles: [:sidekiq] do
  rake 'check_broken_links'
end

every 1.day, at: '04.00 am', roles: [:sidekiq] do
  rake 'home_page_stats'
end

every 1.day, at: '4:30 am', roles: [:sidekiq] do
  rake 'rss:feeds:sync'
end

every 1.day, at: '12:00 am', roles: [:sidekiq] do
  rake 'cleanup_vulnerabilities'
end

every 30.minutes, roles: [:sidekiq] do
  rake 'kb_updater:send_updates', output: { error: '/tmp/kb_updater.err', standard: '/tmp/kb_updater.out' }
end
