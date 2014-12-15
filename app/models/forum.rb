class Forum < ActiveRecord::Base
  validates :name, :topics_count, :posts_count, presence: true
  validates :position, numericality: true, allow_blank: true
  
  has_many :topics
  has_many :posts, through: :topics
end
