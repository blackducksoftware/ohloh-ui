namespace :ci do
  desc 'Run the complete build verification'
  task :all_tasks do
    # FIXME: fix rubocop warnings
    # puts '*** Running Rubocop'
    # exit(1) unless system('rubocop')
    # FIXME: fix haml-lint warnings
    # puts '*** Running HAML-Lint'
    # exit(1) unless system('haml-lint .')
    # puts '*** Running Brakeman'
    # exit(1) unless system('brakeman -qz')
    puts '*** Running Bundle Audit'
    system('bundle exec bundle-audit update && bundle exec bundle-audit check')
    # puts '*** Running teaspoon'
    # exit(1) unless system('RAILS_ENV=test teaspoon --no-color')
    # puts '*** Running Spinach Integration specs'
    # exit(1) unless system('spinach -r console')
    puts '*** Running Rake Test'
    exit(1) unless system('RAILS_ENV=test rake test')
    puts 'PASSED'
  end
end
