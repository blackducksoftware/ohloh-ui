# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/image_helper'
require 'test_helpers/activity_facts_by_commits_data'

describe 'Spark::SimpleSpark' do
  let(:data) { ActivityFactsByMonthData.new(false).data }

  describe '#render' do
    it 'must render commits spark successfully' do
      expected_image_path = Rails.root.join('test', 'data', 'spark', 'simple_spark.png')
      result_file = Spark::SimpleSpark.new(data, max_value: 50).render

      compare_images(result_file.path, expected_image_path, 0.1)
    end
  end
end
