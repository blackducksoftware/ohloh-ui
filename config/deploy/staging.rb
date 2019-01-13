role :web_1, %w[serv-deployer@oh-web01.dc1.lan]
role :web_2, %w[serv-deployer@oh-web02.dc1.lan]
role :web_3, %w[serv-deployer@oh-web03.dc1.lan]
role :web_4, %w[serv-deployer@oh-web04.dc1.lan]
role :web_5, %w[serv-deployer@oh-web05.dc1.lan]
role :web_6, %w[serv-deployer@oh-web06.dc1.lan]
role :web_7, %w[serv-deployer@oh-web07.dc1.lan]
role :web_8, %w[serv-deployer@oh-web08.dc1.lan]

role :selenium, %w[serv-deployer@oh-web03.dc1.lan]

role :db, %w[serv-deployer@oh-utility01.dc1.lan], primary: true

role :utility, %w[serv-deployer@oh-utility01.dc1.lan]

set :user, 'serv-deployer'
set :default_env, 'PATH' => '/home/serv-deployer/.rbenv/shims:$PATH',
                  'BASH_ENV' => '/home/serv-deployer/.production_vars'

# All passenger_roles get a deploy:restart after deploy:publishing.
set :passenger_roles, %i[web web_1 web_2 web_3 web_4 web_5 web_7 web_8]
set :sidekiq_role, [:utility]
set :rails_env, 'staging'

# shared/.env.staging contains environment specific dotenv overrides.
set :linked_files, %w[.env.staging]

set sidekiq_env: fetch(:rails_env)
set :assets_roles, %i[web_1 web_2 web_3 web_4 web_5 web_6 web_7 web_8]
