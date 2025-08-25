# frozen_string_literal: true

namespace :docker do
  desc 'Cuts a new build'
  task :build do
    system 'git rev-parse HEAD > config/GIT_SHA'
    system 'rm log/*.log'
    system 'rm -r tmp/*'
    system 'docker build -t ohloh-ui .'
  end

  desc 'Launches a container with the app'
  task :run do
    system 'docker stop ohloh-ui-app-server'
    system 'docker rm ohloh-ui-app-server'
    system 'docker run --name ohloh-ui-app-server -p 7070:80 -d ohloh-ui'
  end

  desc 'Launches a bash shell into the container'
  task :bash do
    system 'docker exec -it ohloh-ui-app-server /bin/bash'
  end

  desc 'Curls the status page'
  task :status do
    system 'curl http://$(boot2docker ip 2>/dev/null):7070/server_info'
    puts "\n"
  end

  desc 'Opens the status page in a web browser'
  task :open do
    system 'open http://$(boot2docker ip 2>/dev/null):7070/server_info'
  end

  desc 'Tag, Build, and Push a new version of Ohloh-UI'
  task :tag do
    internal_registry = 'coreos.blackducksoftware.com:5000'
    Rake::Task['version:bump'].invoke
    system 'git push'
    version = Rails.root.join('VERSION').read.delete("\n")
    Rake::Task['docker:build'].invoke
    system "docker tag ohloh-ui:latest #{internal_registry}/ohloh-ui:#{version}"
    system "docker push #{internal_registry}/ohloh-ui"
  end
end
