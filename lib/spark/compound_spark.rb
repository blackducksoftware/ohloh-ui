class CompoundSpark < Spark
  SPARK = { column_width: 3, column_gap: 1, column_base: 1, column_variant: 25, blank_row: 1,
            label_height: 12, label_point_size: 11, max_value: 100, graph_padding: 27 }

  def render
    image do |covert|
      @data.each_with_index do |commits_by_month, i|
        time = Time.parse(commits_by_month.month)
        color = (time.month == 1) ? 'black' : nil
        convert.draw draw_tick(commits_by_month.commits.to_i, i, color)
      end
    end
  end

  private

  def image
    new_image do |convert|
      convert.size "#{width}x#{height}"
      convert << 'xc:white'
      convert.stroke 'none'
      yield convert
    end
  end

  def draw_tick(datum, i, max)
    time = Time.parse(datum['month'])
    value = datum['commits'].to_i
    image do |convert|
      convert.draw "stroke_width none stroke_opacity 0 fill_opacity 0"
      commits_bar(commits_count, index, color)
      if (time.year % 2 == 0 and time.month == 1)
        convert.draw even_years_starting_month_rectangle
        convert.draw even_years_starting_month_annotation
      end
    end
  end

  def even_years_starting_month_rectangle
    "fill light_gray rectangle #{x_axis_value}, #{y_axis_value - COLUMN_BASE} "\
    "#{x_axis_value + @column_width - 1}, #{COLUMN_BASE}"
  end

  def even_years_starting_month_annotation
    "fill dark_gray font_family sans stroke none pointsize #{LABEL_POINT_SIZE} font_weight bold"\
    "annotate 0, 0, x_axis_value + 4, y_axis_value + #{LABEL_HEIGHT}, time.year.to_s"
  end

  def scale(value)
    if value >= @max_value
      COLUMN_VARIANT
    else
      (value.to_f / @max_value.to_f * COLUMN_VARIANT).to_i
    end
  end
end
