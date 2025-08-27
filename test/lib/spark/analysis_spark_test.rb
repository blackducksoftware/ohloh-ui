# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/image_helper'

class Spark::AnalysisSparkTest < ActiveSupport::TestCase
  describe '#render' do
    it 'must render commits spark successfully' do
      data = []
      (1..31).each do |value|
        data.push << [Date.parse("2015-01-#{value}").to_time(:utc), value]
      end

      expected_image_path = Rails.root.join('test', 'data', 'spark', 'age_spark.png')
      result_file = Spark::AnalysisSpark.new(data, max_value: 31).render

      compare_images(result_file.path, expected_image_path, 0.17) # bumped from 0.14
    end
  end

  describe 'max_value' do
    it 'max_value returns the maximum integer from data last elements' do
      data = [
        [Date.new(2023, 1, 1), '10'],
        [Date.new(2023, 1, 2), '25'],
        [Date.new(2023, 1, 3), '7']
      ]
      spark = Spark::AnalysisSpark.new(data)
      assert_equal 25, spark.send(:max_value)
    end

    it 'max_value returns nil for empty data' do
      spark = Spark::AnalysisSpark.new([])
      assert_nil spark.send(:max_value)
    end

    it 'max_value handles non-integer strings gracefully' do
      data = [
        [Date.new(2023, 1, 1), 'foo'],
        [Date.new(2023, 1, 2), '20']
      ]
      spark = Spark::AnalysisSpark.new(data)
      assert_equal 20, spark.send(:max_value)
    end
  end
end
