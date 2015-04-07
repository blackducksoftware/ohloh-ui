class Spark::Spark
  IMAGE_DIR = Rails.root.join('app/assets/images/')
  SPARK = { column_width: 2, column_gap: 1, column_base: 1, column_variant: 21, blank_row: 1,
            label_height: 9, max_value: 5000 }

  def initialize(data, options = {})
    @data = data
    @column_width = options[:column_width] || SPARK[:column_width]
    @column_gap = options[:column_gap] || SPARK[:column_gap]
    @max_value = options[:max_value] || max_commits_value
  end

  private

  def column_height
    SPARK[:column_base] + SPARK[:column_variant]
  end

  def height
    column_height + SPARK[:blank_row] + SPARK[:label_height]
  end

  def width
    width = (@data.size * @column_width) + ((@data.size - 1) * @column_gap).to_i
    width += SPARK[:graph_padding] if SPARK[:graph_padding].present?
    width
  end

  def max_commits_value
    @data.map(&:commits).map(&:to_i).max
  end

  def x_axis_value(index)
    index * (@column_width + @column_gap)
  end

  def y_axis_value
    column_height
  end

  def commits_bar(commits_count, index)
    dy = commits_count.zero? ? scale(commits_count) : 0
    "rectangle #{x_axis_value(index)}, #{y_axis_value - SPARK[:column_base] - dy} "\
    "#{x_axis_value(index) + @column_width - 1}, #{column_height}"
  end

  def new_image
    tempfile = Tempfile.new(['image-base-', '.png'])

    MiniMagick::Tool::Convert.new do |convert|
      yield convert
      convert << tempfile.path
    end

    image = MiniMagick::Image.open(tempfile.path)
    tempfile.close
    image
  end
end
