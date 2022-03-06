# frozen_string_literal: true

require 'test_helper'

class Project::ActivityLevelIndexTest < ActiveSupport::TestCase
  describe 'demographic_chart_data' do
    it 'should return the computed values when level index is 10' do
      activity = Project::ActivityLevelIndex.new(10, 5, 10)
      _(activity.demographic_chart_data[:name]).must_equal 'New'
      _(activity.demographic_chart_data[:y]).must_equal 50.0
      _(activity.demographic_chart_data[:selected]).must_equal false
      _(activity.demographic_chart_data[:sliced]).must_equal false
    end

    it 'should return the computed values when level index is 20' do
      activity = Project::ActivityLevelIndex.new(20, 5, 10)
      _(activity.demographic_chart_data[:name]).must_equal 'Inactive'
      _(activity.demographic_chart_data[:y]).must_equal 50.0
      _(activity.demographic_chart_data[:selected]).must_equal true
      _(activity.demographic_chart_data[:sliced]).must_equal true
    end

    it 'should return the computed values when level index is 30' do
      activity = Project::ActivityLevelIndex.new(30, 5, 10)
      _(activity.demographic_chart_data[:name]).must_equal 'Very Low'
      _(activity.demographic_chart_data[:y]).must_equal 50.0
      _(activity.demographic_chart_data[:selected]).must_equal false
      _(activity.demographic_chart_data[:sliced]).must_equal false
    end

    it 'should return the computed values when level index is 40' do
      activity = Project::ActivityLevelIndex.new(40, 5, 10)
      _(activity.demographic_chart_data[:name]).must_equal 'Low'
      _(activity.demographic_chart_data[:y]).must_equal 50.0
      _(activity.demographic_chart_data[:selected]).must_equal false
      _(activity.demographic_chart_data[:sliced]).must_equal false
    end

    it 'should return the computed values when level index is 50' do
      activity = Project::ActivityLevelIndex.new(50, 5, 10)
      _(activity.demographic_chart_data[:name]).must_equal 'Moderate'
      _(activity.demographic_chart_data[:y]).must_equal 50.0
      _(activity.demographic_chart_data[:selected]).must_equal false
      _(activity.demographic_chart_data[:sliced]).must_equal false
    end

    it 'should return the computed values when level index is 60' do
      activity = Project::ActivityLevelIndex.new(60, 5, 10)
      _(activity.demographic_chart_data[:name]).must_equal 'High'
      _(activity.demographic_chart_data[:y]).must_equal 50.0
      _(activity.demographic_chart_data[:selected]).must_equal false
      _(activity.demographic_chart_data[:sliced]).must_equal false
    end

    it 'should return the computed values when level index is 70' do
      activity = Project::ActivityLevelIndex.new(70, 5, 10)
      _(activity.demographic_chart_data[:name]).must_equal 'Very High'
      _(activity.demographic_chart_data[:y]).must_equal 50.0
      _(activity.demographic_chart_data[:selected]).must_equal false
      _(activity.demographic_chart_data[:sliced]).must_equal false
    end
  end
end
