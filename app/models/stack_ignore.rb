class StackIgnore < ActiveRecord::Base
  belongs_to :stack
  belongs_to :project

  validates :stack, presence: true
  validates :project, presence: true
end
