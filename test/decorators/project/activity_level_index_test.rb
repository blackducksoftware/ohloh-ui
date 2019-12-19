# frozen_string_literal: true

require 'test_helper'

class Project::ActivityLevelIndexTest < ActiveSupport::TestCase
  describe 'demographic_chart_data' do
    it 'should return the computed values when level index is 10' do
      activity = Project::ActivityLevelIndex.new(10, 5, 10)
      activity.demographic_chart_data[:name].must_equal 'New'
      activity.demographic_chart_data[:color].must_equal '#F27A3F'
      activity.demographic_chart_data[:y].must_equal 50.0
      activity.demographic_chart_data[:selected].must_equal false
      activity.demographic_chart_data[:sliced].must_equal false
    end

    it 'should return the computed values when level index is 20' do
      activity = Project::ActivityLevelIndex.new(20, 5, 10)
      activity.demographic_chart_data[:name].must_equal 'Inactive'
      activity.demographic_chart_data[:color].must_equal '#2369C8'
      activity.demographic_chart_data[:y].must_equal 50.0
      activity.demographic_chart_data[:selected].must_equal true
      activity.demographic_chart_data[:sliced].must_equal true
    end

    it 'should return the computed values when level index is 30' do
      activity = Project::ActivityLevelIndex.new(30, 5, 10)
      activity.demographic_chart_data[:name].must_equal 'Very Low'
      activity.demographic_chart_data[:color].must_equal '#0A1929'
      activity.demographic_chart_data[:y].must_equal 50.0
      activity.demographic_chart_data[:selected].must_equal false
      activity.demographic_chart_data[:sliced].must_equal false
    end

    it 'should return the computed values when level index is 40' do
      activity = Project::ActivityLevelIndex.new(40, 5, 10)
      activity.demographic_chart_data[:name].must_equal 'Low'
      activity.demographic_chart_data[:color].must_equal '#75B134'
      activity.demographic_chart_data[:y].must_equal 50.0
      activity.demographic_chart_data[:selected].must_equal false
      activity.demographic_chart_data[:sliced].must_equal false
    end

    it 'should return the computed values when level index is 50' do
      activity = Project::ActivityLevelIndex.new(50, 5, 10)
      activity.demographic_chart_data[:name].must_equal 'Moderate'
      activity.demographic_chart_data[:color].must_equal '#81000A'
      activity.demographic_chart_data[:y].must_equal 50.0
      activity.demographic_chart_data[:selected].must_equal false
      activity.demographic_chart_data[:sliced].must_equal false
    end

    it 'should return the computed values when level index is 60' do
      activity = Project::ActivityLevelIndex.new(60, 5, 10)
      activity.demographic_chart_data[:name].must_equal 'High'
      activity.demographic_chart_data[:color].must_equal '#149FC0'
      activity.demographic_chart_data[:y].must_equal 50.0
      activity.demographic_chart_data[:selected].must_equal false
      activity.demographic_chart_data[:sliced].must_equal false
    end

    it 'should return the computed values when level index is 70' do
      activity = Project::ActivityLevelIndex.new(70, 5, 10)
      activity.demographic_chart_data[:name].must_equal 'Very High'
      activity.demographic_chart_data[:color].must_equal '#391B59'
      activity.demographic_chart_data[:y].must_equal 50.0
      activity.demographic_chart_data[:selected].must_equal false
      activity.demographic_chart_data[:sliced].must_equal false
    end
  end
end
