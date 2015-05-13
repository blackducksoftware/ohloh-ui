lock '3.4.0'

set :application, 'openhub'
set :repo_url, 'git@github.com:blackducksw/ohloh-ui.git'
set :user, :deployer
set :use_sudo, false
set :branch, ENV['branch'] || :master

set :deploy_to, "/var/local/#{ fetch(:application) }"

# Use remote cache for deployment
set :deploy_via, :remote_cache
set :copy_exclude, ['.git']

# Defaults to false. If true, it's skip migration if files in db/migrate not modified
set :conditionally_migrate, true
