# frozen_string_literal: true

class Topic < ApplicationRecord
  validates :account, :title, :hits, presence: true
  validates :sticky, :hits, numericality: true
  validates :closed, inclusion: { in: [true, false] }

  belongs_to :account, optional: true
  belongs_to :forum, counter_cache: true, optional: true
  has_many :posts, -> { order('created_at asc') }, inverse_of: :topic, dependent: :destroy
  belongs_to :replied_by_account, foreign_key: 'replied_by', class_name: 'Account', optional: true

  accepts_nested_attributes_for :posts

  scope :recent, -> { where(closed: false).order(replied_at: :desc).limit(10) }
end
