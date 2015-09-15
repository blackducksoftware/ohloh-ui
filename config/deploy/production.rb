role :web, ['deployer@prd-oh-web01.dc2.lan', 'deployer@prd-oh-web02.dc2.lan',
            'deployer@prd-oh-web03.dc2.lan']

# All passenger_roles get a deploy:restart after deploy:publishing.
set :passenger_roles, [:web]
set :rails_env, 'production'

set :linked_files, %w(openhub-config/.env.production)

set :assets_roles, [:web]
