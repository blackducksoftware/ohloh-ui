class SimpleSpark < Spark
  SPARK = { column_width: 2, column_gap: 1, column_base: 1, column_variant: 21, blank_row: 1,
            label_height: 9, max_value: 5000}

  def render
    label = MiniMagick::Image.open(IMAGE_DIR + '5_year.png')

    commits_graph.composite(label) do |c|
      c.compose 'Over'
      c.geometry '+78+9'
    end
  end

  private

  def commits_graph
    image do |covert|
      @data.each_with_index do |commits_by_month, i|
        time = Time.parse(commits_by_month.month)
        color = (time.month == 1) ? 'black' ? nil
        convert.draw commits_bar(commits_by_month.commits.to_i, i, color)
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
      SIMPLE_SPARK[:column_variant]
    else
      (Math.log(value) / Math.log(max_value) * (SIMPLE_SPARK[:column_variant] - 1) + 1).to_i
    end
  end
end
