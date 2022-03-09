# frozen_string_literal: true

class Spark::SimpleSpark < Spark::Base
  SPARK = { column_width: 2, column_gap: 1, column_base: 1, column_variant: 21, blank_row: 1,
            label_height: 9, max_value: 5000 }.freeze
  LIGHT_GRAY = '#a7a7a7'
  DARK_GRAY = '#656565'

  def initialize(data, options = {})
    super(data, SPARK.merge(options))
  end

  def render
    merge_5_year_commit_image_with_spark_image
  end

  private

  def merge_5_year_commit_image_with_spark_image
    label = MiniMagick::Image.open(IMAGE_DIR.join('5_year.png'))
    commits_graph.composite(label) do |c|
      c.compose 'Over'
      c.geometry "+#{width - 78}+#{height - 9}"
    end
  end

  def commits_graph
    image do |convert|
      @data.each_with_index do |commits_by_month, i|
        time = commits_by_month.month
        color = time.month == 1 ? 'black' : nil
        commits_count = commits_by_month.commits.to_i
        color ||= commits_count.zero? ? LIGHT_GRAY : DARK_GRAY
        convert.fill color
        convert.draw draw_rectangle_bar(commits_count, i)
      end
    end
  end

  def image
    new_image do |convert|
      convert.size "#{width}x#{height}"
      convert << 'xc:white'
      convert.stroke 'none'
      yield convert
    end
  end

  def scale(value)
    if [0, 1].include?(value)
      value
    elsif value >= @max_value
      SPARK[:column_variant]
    else
      ((Math.log(value) / Math.log(@max_value) * (SPARK[:column_variant] - 1)) + 1).to_i
    end
  end
end
