namespace :docker do |ns|
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

  desc 'Curls the status page'
  task :status do
    system 'curl http://$(boot2docker ip 2>/dev/null):7070/server_info'
  end

  desc 'Opens the status page in a web browser'
  task :open do
    system 'open http://$(boot2docker ip 2>/dev/null):7070/server_info'
  end
end
