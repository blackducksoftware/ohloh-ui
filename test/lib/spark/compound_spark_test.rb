require 'test_helper'
require 'test_helpers/image_helper'
require 'test_helpers/activity_facts_by_month_compound_spark_data'

describe 'Spark::CompoundSpark' do
  let(:data) { ActivityFactsByMonthCompounSparkData.new.data }

  describe '#render' do
    it 'must render commits spark successfully' do
      expected_image_path = Rails.root.join('test', 'data', 'spark', 'compound_spark.png')
      result_file = Spark::CompoundSpark.new(data, max_value: 50).render

      compare_images(result_file.path, expected_image_path, 0.1)
    end

    it 'must render commits spark successfully when max value is not specified' do
      expected_image_path = Rails.root.join('test', 'data', 'spark', 'compound_commits_spark_without_max.png')
      result_file = Spark::CompoundSpark.new(data).render

      compare_images(result_file.path, expected_image_path, 0.1)
    end
  end
end
