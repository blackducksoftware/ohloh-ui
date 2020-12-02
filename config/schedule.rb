# frozen_string_literal: true

require 'dotenv'
Dotenv.load('.env.production', '.env')

env :PATH, ENV['PATH']
set :environment, 'production'
set :output, error: 'log/cron_error.log', standard: 'log/cron.log'

bash_cmd = "/bin/bash -l -c ':job'"
curl_cmd = 'curl -fsS --retry 5 -o /dev/null'

set :job_template, "#{bash_cmd} && #{curl_cmd} #{ENV['HC_CHECK_BROKEN_LINKS_URL']}"
every 2.weeks, at: '11.00 am', roles: [:sidekiq] do
  rake 'check_broken_links'
end

set :job_template, "#{bash_cmd} && #{curl_cmd} #{ENV['HC_HOME_PAGE_STATS_URL']}"
every 1.day, at: '04.00 am', roles: [:sidekiq] do
  rake 'home_page_stats'
end

set :job_template, "#{bash_cmd} && #{curl_cmd} #{ENV['HC_RSS_FEEDS_SYNC_URL']}"
every 1.day, at: '4:30 am', roles: [:sidekiq] do
  rake 'rss:feeds:sync'
end

set :job_template, "#{bash_cmd} && #{curl_cmd} #{ENV['HC_CLEANUP_VULNERABILITIES_URL']}"
every 1.day, at: '12:00 am', roles: [:sidekiq] do
  rake 'cleanup_vulnerabilities'
end

set :job_template, "#{bash_cmd} && #{curl_cmd} #{ENV['HC_KB_SEND_UPDATES_URL']}"
every 30.minutes, roles: [:sidekiq] do
  rake 'kb_updater:send_updates', output: { error: '/tmp/kb_updater.err', standard: '/tmp/kb_updater.out' }
end
