class OrgStatsBySector < ActiveRecord::Base
  class << self
    def recent
      order('id DESC').limit(4).sort_by(&:organization_count).reverse
    end
  end
end
