# frozen_string_literal: true

require 'test_helper'

class Project::DemographicChartTest < ActiveSupport::TestCase
  describe 'data' do
    it 'should return the computed chart data' do
      Project.update_all(activity_level_index: nil)
      create(:project, name: 'test1', activity_level_index: nil)
      create(:project, name: 'test2', activity_level_index: nil)
      create(:project, name: 'test3', activity_level_index: nil)
      create(:project, name: 'test4', activity_level_index: nil)
      create(:project, name: 'testa', activity_level_index: 20)
      create(:project, name: 'testb', activity_level_index: 20)
      create(:project, name: 'testc', activity_level_index: 20)
      create(:project, name: 'testd', activity_level_index: 40)
      create(:project, name: 'teste', activity_level_index: 40)

      data = Project::DemographicChart.data
      data['plotOptions']['pie']['startAngle'].must_equal(-18.0)
      data['series'].first['type'].must_equal 'pie'
      inactive_data = data['series'].last['data'].first
      low_active_data = data['series'].last['data'].last

      inactive_data[:name].must_equal 'Inactive'
      inactive_data[:color].must_equal '#2369C8'
      inactive_data[:y].must_equal 60.0
      inactive_data[:selected].must_equal true
      inactive_data[:sliced].must_equal true

      low_active_data[:name].must_equal 'Low'
      low_active_data[:color].must_equal '#75B134'
      low_active_data[:y].must_equal 40.0
      low_active_data[:selected].must_equal false
      low_active_data[:sliced].must_equal false
    end
  end
end
