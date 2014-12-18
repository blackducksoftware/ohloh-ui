class StackEntry < ActiveRecord::Base
	belongs_to :stack
	belongs_to :project
end
