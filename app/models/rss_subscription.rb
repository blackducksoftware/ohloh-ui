class RssSubscription < ActiveRecord::Base
  belongs_to :project
  belongs_to :rss_feed

  acts_as_editable
  acts_as_protected parent: :project
end
