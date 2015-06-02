role :web, ["#{fetch(:whoami)}@prd-oh-web01.dc2.lan", "#{fetch(:whoami)}@prd-oh-web02.dc2.lan",
            "#{fetch(:whoami)}@prd-oh-web03.dc2.lan"]
role :web_1, ["#{fetch(:whoami)}@prd-oh-web01.dc2.lan"]
role :web_2, ["#{fetch(:whoami)}@prd-oh-web02.dc2.lan"]
role :web_3, ["#{fetch(:whoami)}@prd-oh-web03.dc2.lan"]

# All passenger_roles get a deploy:restart after deploy:publishing.
set :passenger_roles, [:web, :web_1, :web_2, :web_3]
set :rails_env, 'production'

set :assets_roles, [:web, :web_1, :web_2, :web_3]
