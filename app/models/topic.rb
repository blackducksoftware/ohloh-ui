class Topic < ActiveRecord::Base
  validates :title, :hits, :sticky, presence: true
  validates :sticky, :hits, numericality: true
  validates :closed, inclusion: { in: [true, false] }

  belongs_to :account
  belongs_to :forum
  has_many :posts, inverse_of: :topic, dependent: :destroy

  accepts_nested_attributes_for :posts
end
