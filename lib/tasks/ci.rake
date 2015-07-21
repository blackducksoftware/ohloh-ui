namespace :ci do
  desc 'Run the complete build verification'
  task :all_tasks do
    exit(1) unless system('RAILS_ENV=test rake test')
    exit(1) unless system('rubocop')
    exit(1) unless system('brakeman -qz')
    exit(1) unless system('haml-lint .')
    exit(1) unless system('bundle exec bundle-audit update && bundle exec bundle-audit check')
    puts 'PASSED'
  end
end
