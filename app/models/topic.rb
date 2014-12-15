class Topic < ActiveRecord::Base
  validates :account, :forum, :title, :hits, :sticky, :posts_count, presence: true
  validates :sticky, :posts_count, :hits, numericality: true
  validates :closed, inclusion: {in: [true,false]}

  belongs_to :account
  belongs_to :forum
  has_many :posts, inverse_of: :topic, dependent: :destroy

  accepts_nested_attributes_for :posts
end
