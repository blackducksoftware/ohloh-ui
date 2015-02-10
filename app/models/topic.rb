class Topic < ActiveRecord::Base
  validates :title, :hits, presence: true
  validates :sticky, :hits, numericality: true
  validates :closed, inclusion: { in: [true, false] }

  belongs_to :account
  belongs_to :forum
  has_many :posts, -> { order('created_at desc') }, inverse_of: :topic, dependent: :destroy

  accepts_nested_attributes_for :posts
end
