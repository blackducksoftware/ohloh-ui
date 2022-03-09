# frozen_string_literal: true

require 'test_helper'

class SparkDataTest < ActiveSupport::TestCase
  describe 'generate' do
    it 'should generate age spark data' do
      create_project_and_analysis

      spark_data = Analysis::SparkData.generate
      _(spark_data.length).must_equal 64
      data_with_values = spark_data.reject { |datum| datum.last.zero? }
      _(data_with_values.map(&:first)).must_equal [(Date.current - 2.days).to_time(:utc),
                                                   (Date.current - 1.day).to_time(:utc),
                                                   Date.current.to_time(:utc)]
      _(data_with_values.map(&:last)).must_equal [2, 2, 2]
    end
  end
end
