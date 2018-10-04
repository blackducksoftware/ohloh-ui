set :environment, 'production'
every 2.days, at: '11.00 am', roles: [:sidekiq] do
  rake check_broken_links
end
