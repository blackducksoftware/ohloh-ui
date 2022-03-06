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
      _(data['plotOptions']['pie']['startAngle']).must_equal(-18.0)
      _(data['series'].first['type']).must_equal 'pie'
      inactive_data = data['series'].last['data'].first
      low_active_data = data['series'].last['data'].last

      _(inactive_data[:name]).must_equal 'Inactive'
      _(inactive_data[:y]).must_equal 60.0
      _(inactive_data[:selected]).must_equal true
      _(inactive_data[:sliced]).must_equal true

      _(low_active_data[:name]).must_equal 'Low'
      _(low_active_data[:y]).must_equal 40.0
      _(low_active_data[:selected]).must_equal false
      _(low_active_data[:sliced]).must_equal false
    end
  end
end
