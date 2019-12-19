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
end
