class Forum < ActiveRecord::Base
  validates :name, :topics_count, :posts_count, presence: true
  validates :position, numericality: true, allow_blank: true
  
  has_many :topics, -> { order('sticky desc, replied_at desc') }, dependent: :destroy
  has_many :posts, -> { order ('created_at desc') }, through: :topics

  #New feature:
  #Need to add sort functionality to topics and posts

end
