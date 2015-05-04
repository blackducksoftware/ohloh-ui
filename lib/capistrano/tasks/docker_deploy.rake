namespace :docker do
  desc 'deploy a specified tag'
  task :deploy do
    on roles(:all), in: :parallel do
      execute('docker stop ohloh-ui || :')
      execute('docker rm ohloh-ui || :')
      execute("docker run -p 7070:80 --name ohloh-ui -d coreos.blackducksoftware.com:5000/ohloh-ui:#{ENV['tag']}")
    end
  end
end
