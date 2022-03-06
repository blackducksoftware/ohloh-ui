# frozen_string_literal: true

require 'test_helper'

class TopCommitVolumeChartTest < ActiveSupport::TestCase
  describe 'data' do
    it 'should return chart data' do
      name_fact = create(:name_fact, thirty_day_commits: 5, twelve_month_commits: 8, commits: 50)
      analysis = name_fact.analysis
      data = Analysis::TopCommitVolumeChart.new(analysis).data

      _(data['series'].first['name']).must_equal name_fact.name.name
      _(data['series'].first['data']).must_equal [50, 8, 5]
      _(data['series'].last['name']).must_equal 'Other'
      _(data['series'].last['data']).must_equal [0, 0, 0]
      _(data['warnining']).must_be_nil
    end
  end
end
