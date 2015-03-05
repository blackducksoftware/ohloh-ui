require 'test_helper'

class OrgThrityDayActivityDecoratorTest < ActiveSupport::TestCase
  describe 'project_count_text' do
    it 'should return "S" for small orgs' do
      ota = create(:org_thirty_day_activity, project_count: 8).decorate
      ota.project_count_text.must_equal 'S'
    end

    it 'should return "M" for medium orgs' do
      ota = create(:org_thirty_day_activity, project_count: 12).decorate
      ota.project_count_text.must_equal 'M'
    end

    it 'should return "L" for large orgs' do
      ota = create(:org_thirty_day_activity, project_count: 55).decorate
      ota.project_count_text.must_equal 'L'
    end

    it 'should return "N/A" with no projects' do
      ota = create(:org_thirty_day_activity, project_count: 0).decorate
      ota.project_count_text.must_equal 'N/A'
    end
  end
end
