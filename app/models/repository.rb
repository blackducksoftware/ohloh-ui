class Repository < ActiveRecord::Base
  has_many :enlistments
  has_many :projects, through: :enlistments
end
