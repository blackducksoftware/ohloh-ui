# frozen_string_literal: true

require 'test_helper'

class OrgStatsBySectorTest < ActiveSupport::TestCase
  describe 'recent' do
    it 'should fetch last four orgs stats by sector and sort it by' do
      stat1 = create(:org_stats_by_sector)
      stat2 = create(:org_stats_by_sector, org_type: 2, organization_count: 20)
      stat3 = create(:org_stats_by_sector, org_type: 3, organization_count: 40)
      stat4 = create(:org_stats_by_sector, org_type: 4, organization_count: 50)
      _(OrgStatsBySector.recent).must_equal [stat4, stat3, stat2, stat1]
    end
  end
end
