# frozen_string_literal: true

# rubocop:disable HasManyOrHasOneDependent

class RssSubscription < ActiveRecord::Base
  belongs_to :project
  belongs_to :rss_feed
  has_one :create_edit, as: :target
  acts_as_editable
  acts_as_protected parent: :project

  validates :rss_feed_id, presence: true, uniqueness: { scope: :project_id }

  filterable_by ['rss_feeds.url']

  scope :not_deleted, -> { where(deleted: false) }

  def explain_yourself
    I18n.t('.rss_subscriptions.index.explain', url: rss_feed.url)
  end
end

# rubocop:enable HasManyOrHasOneDependent
