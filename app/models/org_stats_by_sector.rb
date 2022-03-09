# frozen_string_literal: true

class OrgStatsBySector < ApplicationRecord
  class << self
    def recent
      order(id: :desc).limit(4).sort_by(&:organization_count).reverse
    end
  end
end
