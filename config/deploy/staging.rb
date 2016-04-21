role :web_1, %w(deployer@oh-stage-web-1.blackducksoftware.com)
role :web_2, %w(deployer@oh-stage-web-2.blackducksoftware.com)
role :web_3, %w(deployer@oh-stage-web-3.blackducksoftware.com)
role :web_5, %w(core@10.1.1.106)
role :web_7, %w(deployer@oh-stage-web-7.blackducksoftware.com)
role :db, %w(deployer@oh-stage-utility-2.blackducksoftware.com), primary: true

# All passenger_roles get a deploy:restart after deploy:publishing.
set :passenger_roles, [:web, :web_1, :web_2, :web_3, :web_5, :web_7]
set :rails_env, 'staging'

# shared/.env.staging contains environment specific dotenv overrides.
set :linked_files, %w(.env.staging)

set :assets_roles, [:web, :web_1, :web_2, :web_3, :web_5, :web_7]
