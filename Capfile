# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

require 'capistrano/rails'
require 'capistrano/faster_assets'
require 'capistrano/passenger'

require 'capistrano/sidekiq'
# Load custom tasks from `lib/capistrano/tasks' if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }

require 'capistrano/rbenv'
set :rbenv_type, :user
set :rbenv_ruby, '2.2.3'

require 'new_relic/recipes'
