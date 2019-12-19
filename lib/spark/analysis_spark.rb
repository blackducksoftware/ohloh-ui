# frozen_string_literal: true

class Spark::AnalysisSpark < Spark::Base
  SPARK = { column_width: 4, column_gap: 1, column_base: 1, column_variant: 75, blank_row: 1,
            label_height: 14, label_point_size: 12, max_value: 100 }.freeze

  LIGHT_GRAY = '#ddd'
  DARK_GRAY = '#a7a7a7'
  FONT = Rails.root.join('app', 'assets', 'fonts', 'OpenSans-Bold.ttf').freeze

  def initialize(data, options = {})
    super(data, SPARK.merge(options))
  end

  def render
    image do |convert|
      @data.each_with_index do |analyis_by_day, i|
        draw_bar(convert, analyis_by_day, i)
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

  def max_value
    @data.map(&:last).map(&:to_i).max
  end

  def bar_color(datum)
    return 'black' if datum.first.day == 1

    datum.last.to_i.zero? ? LIGHT_GRAY : DARK_GRAY
  end

  def draw_bar(convert, datum, index)
    convert.fill bar_color(datum)
    convert.draw draw_rectangle_bar(datum.last.to_i, index)
    draw_bottom_text(convert, datum.first, index)
  end

  def draw_bottom_text(convert, time, index)
    return convert unless time.day == 1

    draw_bottom_pointer(convert, index)
    set_text_style(convert)
    convert.draw "text #{x1_axis_value(index) + 6},#{y2_axis_value + SPARK[:label_height] - 2} "\
                 "#{time.strftime('%b')}"
  end

  def set_text_style(convert)
    convert.fill DARK_GRAY
    convert.font FONT
    convert.pointsize SPARK[:label_point_size]
  end

  def draw_bottom_pointer(convert, index)
    convert.fill DARK_GRAY
    convert.draw "rectangle #{x1_axis_value(index)}, #{y1_axis_value(0) + SPARK[:label_height]} \
    #{x2_axis_value(index)}, #{y2_axis_value + SPARK[:column_base]}"
  end

  def scale(value)
    if value >= @max_value
      SPARK[:column_variant]
    else
      (value.fdiv(@max_value) * SPARK[:column_variant]).to_i
    end
  end
end
