class Forum < ActiveRecord::Base
  validates :name, presence: true
  validates :position, numericality: { only_integer: true }, allow_blank: true
  validates :position, length: { maximum: 9 }

  has_many :topics, -> { order('sticky desc, replied_at desc') }, dependent: :destroy
  has_many :posts, through: :topics
end
