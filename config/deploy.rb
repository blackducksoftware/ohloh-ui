lock '3.4.0'

set :whoami, `whoami`.strip
set :default_env, 'PATH' => '/home/deployer/.rbenv/shims:$PATH'

set :application, 'openhub'
set :bundle_gemfile, -> { release_path.join('Gemfile') }
set :bundle_path, -> { shared_path.join('bundle') }
set :repo_url, 'git@github.com:blackducksw/ohloh-ui.git'
set :user, 'deployer'
set :use_sudo, false
set :passenger_restart_with_sudo, false
set :branch, ENV['branch'] || :master
role :reverification_server, ['deployer@oh-stage-web-7.blackducksoftware.com']

set :deploy_to, "/var/local/#{fetch(:application)}"

# Use remote cache for deployment
set :deploy_via, :remote_cache
set :copy_exclude, ['.git']

# Defaults to false. If true, it's skip migration if files in db/migrate not modified
set :conditionally_migrate, true
set :whenever_command, 'bundle exec whenever'
set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }
set :whenever_roles, -> { :reverification_server }

before 'deploy:check:linked_files', 'deploy:update_configuration'
