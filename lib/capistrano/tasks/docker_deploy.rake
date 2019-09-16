# frozen_string_literal: true

namespace :docker do
  desc 'deploy a specified tag'
  task :deploy do
    on roles(:all), in: :parallel do
      execute('docker stop ohloh-ui || :')
      execute('docker rm ohloh-ui || :')
      build_version = "coreos.blackducksoftware.com:5000/ohloh-ui:#{ENV['tag']}"
      execute("docker run -p 7070:80 --name ohloh-ui -d -e PASSENGER_APP_ENV=#{fetch(:rails_env)} #{build_version}")
    end
  end
end
