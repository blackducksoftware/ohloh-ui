# frozen_string_literal: true

# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

require 'capistrano/rails'
require 'capistrano/faster_assets'
require 'capistrano/passenger'

require 'whenever/capistrano'
require 'capistrano/sidekiq'
# Load custom tasks from `lib/capistrano/tasks' if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }

require 'capistrano/rbenv'
set :rbenv_type, :user
set :rbenv_ruby, '2.5.3'

require 'new_relic/recipes'
