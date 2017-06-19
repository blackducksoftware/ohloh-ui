namespace :ci do
  desc 'Run the complete build verification'
  task :all_tasks do
    puts '*** Running Rubocop'
    exit(1) unless system('rubocop')
    puts '*** Running HAML-Lint'
    exit(1) unless system('haml-lint .')
    puts '*** Running Brakeman'
    exit(1) unless system('brakeman -qz')
    puts '*** Running Bundle Audit'
    exit(1) unless system('bundle exec bundle-audit update && bundle exec bundle-audit check')
    puts '*** Running teaspoon'
    exit(1) unless system('RAILS_ENV=test teaspoon --no-color')
    puts '*** Running Rake Test'
    exit(1) unless system('RAILS_ENV=test rake test')
    puts 'PASSED'
  end
end
