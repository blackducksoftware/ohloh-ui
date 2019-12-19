# frozen_string_literal: true

require 'test_helper'

class TopCommitVolumeChartTest < ActiveSupport::TestCase
  describe 'data' do
    it 'should return chart data' do
      name_fact = create(:name_fact, thirty_day_commits: 5, twelve_month_commits: 8, commits: 50)
      analysis = name_fact.analysis
      data = Analysis::TopCommitVolumeChart.new(analysis).data

      data['series'].first['name'].must_equal name_fact.name.name
      data['series'].first['data'].must_equal [50, 8, 5]
      data['series'].last['name'].must_equal 'Other'
      data['series'].last['data'].must_equal [0, 0, 0]
      assert_nil data['warnining']
    end
  end
end
