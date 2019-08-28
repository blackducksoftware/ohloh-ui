# frozen_string_literal: true

class StatusController < ApplicationController
  def age_spark
    image = Rails.cache.fetch('analysis_age_spark', expires_in: 1.hour) do
      data = Analysis::SparkData.generate
      Spark::AnalysisSpark.new(data, max_value: Project.with_analysis.count / 2).render.to_blob
    end
    send_data(image, type: 'image/png', filename: 'age_spark.png', disposition: 'inline')
  end
end
