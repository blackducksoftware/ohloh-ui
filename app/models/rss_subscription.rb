class RssSubscription < ActiveRecord::Base
  belongs_to :project

  acts_as_editable
  acts_as_protected parent: :project
end
