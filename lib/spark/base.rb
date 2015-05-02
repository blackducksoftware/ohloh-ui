class Spark::Base
  include MiniMagickHelper

  IMAGE_DIR = Rails.root.join('app/assets/images/')

  def initialize(data, options = {})
    @data = data
    @spark = options
    @max_value = options[:max_value] || max_commits_value
  end

  private

  def column_height
    @spark[:column_base] + @spark[:column_variant]
  end

  def height
    column_height + @spark[:blank_row] + @spark[:label_height]
  end

  def width
    width = (@data.size * @spark[:column_width]) + ((@data.size - 1) * @spark[:column_gap]).to_i
    width += @spark[:graph_padding] if @spark[:graph_padding].present?
    width
  end

  def max_commits_value
    @data.map(&:commits).map(&:to_i).max
  end

  def x1_axis_value(index)
    index * (@spark[:column_width] + @spark[:column_gap])
  end

  def y1_axis_value(commits_count)
    dy = commits_count.zero? ? 0 : scale(commits_count)
    column_height - @spark[:column_base] - dy
  end

  def x2_axis_value(index)
    x1_axis_value(index) + @spark[:column_width] - 1
  end

  def y2_axis_value
    column_height
  end

  def draw_rectangle_bar(commits_count, index)
    "rectangle #{x1_axis_value(index)}, #{y1_axis_value(commits_count)} #{x2_axis_value(index)}, #{y2_axis_value}"
  end
end
