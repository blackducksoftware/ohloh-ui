class Review < ActiveRecord::Base
  belongs_to :account
  belongs_to :project
  has_many :helpfuls
end
