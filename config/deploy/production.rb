# frozen_string_literal: true

on ['serv-deployer@prd-oh-web04.dc2.lan', 'serv-deployer@prd-oh-web05.dc2.lan', 'serv-deployer@prd-oh-web06.dc2.lan'] do
  within '/home/serv-deployer' do
    execute('wget -O docker-compose.yml https://raw.githubusercontent.com/blackducksoftware/ohloh-ui/master/docker-compose.yml')
    execute('docker pull sigsynopsys/openhub:latest')
  end
end

# Run the bundle install, assets on one of the web host
on ['serv-deployer@prd-oh-web06.dc2.lan'] do
  within '/home/serv-deployer' do
    execute('docker-compose run --rm web bundle install')
    execute('docker-compose run --rm web bundle exec rake assets:precompile RAILS_ENV=production')
  end
end

# Rebuild the container with the latest changes (code, assets)
on ['serv-deployer@prd-oh-web04.dc2.lan', 'serv-deployer@prd-oh-web05.dc2.lan', 'serv-deployer@prd-oh-web06.dc2.lan'] do
  within '/home/serv-deployer' do
    execute('docker-compose up -d --build')
  end
end
