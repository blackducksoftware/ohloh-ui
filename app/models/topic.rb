class Topic < ActiveRecord::Base
  validates :account, :title, :hits, presence: true
  validates :sticky, :hits, numericality: true
  validates :closed, inclusion: { in: [true, false] }

  belongs_to :account
  belongs_to :forum, counter_cache: true
  has_many :posts, -> { order('created_at asc') }, inverse_of: :topic, dependent: :destroy
  belongs_to :replied_by_account, foreign_key: 'replied_by', class_name: 'Account'

  before_create { |r| r.replied_at = Time.now.utc }

  accepts_nested_attributes_for :posts

  scope :recent, -> { where(closed: false).order(replied_at: :desc).limit(10) }
end
