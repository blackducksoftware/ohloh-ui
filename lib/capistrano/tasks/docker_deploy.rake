# frozen_string_literal: true

namespace :docker do
  task :deploy do
    on fetch(:web_heads), in: :parallel do
      execute('wget -O docker-compose.yml https://raw.githubusercontent.com/blackducksoftware/ohloh-ui/master/docker-compose.yml')
      execute('docker pull sigsynopsys/openhub:latest')
    end

    # Run the bundle install, assets on one of the web host
    on fetch(:web_heads).last do
      execute('docker-compose run --rm web bundle install')
      execute('docker-compose run --rm web bundle exec rake assets:precompile RAILS_ENV=production')
    end

    # Rebuild the container with the latest changes (code, assets)
    on fetch(:web_heads), in: :parallel do
      execute('docker-compose up -d --build')
    end
  end
end

namespace :docker do
  task :offline do
    ask(:input, 'Are you sure you want to put the site in MAINTENANCE mode? (y/n)')
    if fetch(:input).to_s.downcase == 'y'
      on fetch(:web_heads), in: :parallel do
        execute('docker pull sigsynopsys/openhub:offline')
        execute('docker stop $DOCKER_HOST_NAME')
        execute('docker run --name=offline --rm -d -p 443:443 sigsynopsys/openhub:offline')
      end
      puts 'Please run cap production deploy:online to bring the site back online.'
    end
  end

  task :online do
    on fetch(:web_heads), in: :parallel do
      execute('docker stop offline')
      execute('docker start $DOCKER_HOST_NAME')
    end
  end

  task :utility do
    on fetch(:utility) do
      execute('wget -O docker-compose.yml https://raw.githubusercontent.com/blackducksoftware/ohloh-ui/master/docker-compose-utility.yml')
      execute('docker pull sigsynopsys/openhub:latest')
      execute('docker-compose up -d --build')
    end
  end
end
