role :web, ['deployer@prd-oh-web01.dc2.lan', 'deployer@prd-oh-web02.dc2.lan',
            'deployer@prd-oh-web03.dc2.lan']

role :utility, 'serv-deployer@prd-oh-utility01.dc2.lan', user: 'serv-deployer'

set :sidekiq_role, [:utility]
set sidekiq_env: fetch(:rails_env)

# All passenger_roles get a deploy:restart after deploy:publishing.
set :passenger_roles, [:web]
set :rails_env, 'production'

set :linked_files, %w[.env.production]

set :assets_roles, [:web]
