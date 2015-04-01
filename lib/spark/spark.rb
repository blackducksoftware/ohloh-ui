class Spark
  IMAGE_DIR = Rails.root.join('app/assets/images/')

  def initialize(data, options = {})
    @data = data
    @column_width = options[:column_width] || COLUMN_WIDTH
    @column_gap = options[:column_gap] || COLUMN_GAP
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
    width = (@data.size * @column_width) + ((@data.size - 1) * @column_gap)
    width += SPARK[:graph_padding] if defined?(SPARK[:graph_padding])
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

  def commits_bar(commits_count, index, color)
    if commits_count == 0
      color ||= 'light_gray'
      "fill #{color} rectangle #{x_axis_value}, #{y_axis_value - COLUMN_BASE} "\
      "#{x_axis_value + @column_width - 1}, y_axis_value"
    else
      color ||= 'dark_gray'
      dy = scale(commits_count)
      "fill #{color} rectangle #{x_axis_value}, #{y_axis_value - COLUMN_BASE - dy} "\
      "#{x_axis_value + @column_width - 1}, y_axis_value"
    end
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
