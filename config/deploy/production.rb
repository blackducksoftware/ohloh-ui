role :web, ['deployer@prd-oh-web01.dc2.lan', 'deployer@prd-oh-web02.dc2.lan',
            'deployer@prd-oh-web03.dc2.lan']

role :sidekiq, %w[deployer@prd-oh-utility01.dc2.lan]
set :sidekiq_role, [:sidekiq]

# All passenger_roles get a deploy:restart after deploy:publishing.
set :passenger_roles, [:web]
set :rails_env, 'production'

set :linked_files, %w[.env.production]
set sidekiq_env: fetch(:rails_env)

set :assets_roles, [:web]
