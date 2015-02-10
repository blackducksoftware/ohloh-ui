require_relative 'lib/decorator'
require_relative 'lib/decoratable'

module Cherry
end

ActiveRecord::Base.send :include, Cherry::Decoratable
