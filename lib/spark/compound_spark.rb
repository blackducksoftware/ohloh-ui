class Spark::CompoundSpark < Spark::Base
  SPARK = { column_width: 3, column_gap: 1, column_base: 1, column_variant: 25, blank_row: 1,
            label_height: 12, label_point_size: 11, max_value: 100, graph_padding: 27 }.freeze

  LIGHT_GRAY = '#a7a7a7'.freeze
  DARK_GRAY = '#656565'.freeze
  FONT = Rails.root.join('app', 'assets', 'fonts', 'OpenSans-Bold.ttf').freeze

  def initialize(data, options = {})
    super(data, SPARK.merge(options))
  end

  def render
    image do |convert|
      @data.each_with_index do |commits_by_month, i|
        draw_commits_bar(convert, commits_by_month, i)
      end
    end
  end

  private

  def image
    new_image do |convert|
      convert.size "#{width}x#{height}"
      convert << 'xc:none'
      convert.stroke 'none'
      yield convert
    end
  end

  def get_commits_color(datum)
    return 'black' if datum.month.month == 1

    datum.commits.to_i.zero? ? LIGHT_GRAY : DARK_GRAY
  end

  def draw_commits_bar(convert, datum, index)
    convert.fill get_commits_color(datum)
    convert.draw draw_rectangle_bar(datum.commits.to_i, index)
    draw_bottom_year_text(convert, datum.month, index)
  end

  def draw_bottom_year_text(convert, time, index)
    return convert unless time.year.even? && time.month == 1

    draw_bottom_year_pointer(convert, index)
    set_text_style(convert)
    convert.draw "text #{x1_axis_value(index) + 4},#{y2_axis_value + SPARK[:label_height]} '#{time.year}'"
  end

  def set_text_style(convert)
    convert.fill DARK_GRAY
    convert.font FONT
    convert.pointsize SPARK[:label_point_size]
  end

  def draw_bottom_year_pointer(convert, index)
    convert.fill LIGHT_GRAY
    convert.draw "rectangle #{x1_axis_value(index)}, #{y1_axis_value(0) + SPARK[:label_height]} \
    #{x2_axis_value(index)}, #{y2_axis_value + SPARK[:column_base]}"
  end

  def scale(value)
    if value >= @max_value
      SPARK[:column_variant]
    else
      (value.to_f / @max_value.to_f * SPARK[:column_variant]).to_i
    end
  end
end
