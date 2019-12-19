# frozen_string_literal: true

class OrgStatsBySector < ActiveRecord::Base
  class << self
    def recent
      order(id: :desc).limit(4).sort_by(&:organization_count).reverse
    end
  end
end
