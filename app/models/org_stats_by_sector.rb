class OrgStatsBySector < ActiveRecord::Base
  scope :recent, -> { order(['id DESC', 'organization_count DESC']).limit(4) }
end
