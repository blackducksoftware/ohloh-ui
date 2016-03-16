role :web, %w(deployer@oh-testing-web-1.blackducksoftware.com)
role :crawl, %w(deployer@oh-testing-crawl-1.blackducksoftware.com)
role :utility, %w(deployer@oh-testing-utility-1.blackducksoftware.com)

# All passenger_roles get a deploy:restart after deploy:publishing.
set :passenger_roles, [:web]
set :rails_env, 'testing' 

# shared/.env.testing contains environment specific dotenv overrides.
set :linked_files, %w(.env.testing)

set :assets_roles, [:web]
