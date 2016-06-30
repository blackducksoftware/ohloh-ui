namespace :deploy do
  desc 'Sync openhub-config data in shared/openhub-config'
  task :update_configuration do
    on roles(:all) do
      config_dir_path = shared_path.join('openhub-config')

      if test "[ -e #{config_dir_path}/.git ]"
        execute :git, '-C', config_dir_path, :pull
      else
        execute(:git, :clone, 'git@github.com:blackducksoftware/openhub-config', config_dir_path)
      end

      config_path = config_dir_path.join('.env.*')
      execute(:cp, config_path, shared_path)
    end
    on roles(:sidekiq) do
      set :linked_files, %w(.env.production log/sidekiq.log)
    end
  end
end
