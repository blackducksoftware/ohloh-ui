# frozen_string_literal: true

require 'test_helper'

class AgeHistogramTest < ActiveSupport::TestCase
  describe 'execute' do
    it 'should generate histogram data' do
      create_project_and_analysis

      histogram_data = Analysis::AgeHistogram.execute
      _(histogram_data.length).must_equal 3
      _(histogram_data.first.logged_date.class).must_equal ActiveSupport::TimeWithZone
      _(histogram_data.first.logged_date).must_equal((Date.current - 2.days).to_time(:utc))
      _(histogram_data.first.value).must_equal 2
      _(histogram_data.second.logged_date).must_equal((Date.current - 1.day).to_time(:utc))
      _(histogram_data.second.value).must_equal 2
      _(histogram_data.third.logged_date).must_equal Date.current.to_time(:utc)
      _(histogram_data.third.value).must_equal 2
    end
  end
end
