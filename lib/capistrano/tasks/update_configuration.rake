namespace :deploy do
  desc 'Sync openhub-config data in shared/openhub-config'
  task :update_configuration do
    on roles(:all) do
      config_dir_path = shared_path.join('openhub-config')

      if test "[ -e #{ config_dir_path }/.git ]"
        execute :git, '-C', config_dir_path, :pull
      else
        execute(:git, :clone, 'git@github.com:blackducksoftware/openhub-config', config_dir_path)
      end
    end
  end
end
