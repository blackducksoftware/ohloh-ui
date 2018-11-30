class Chart::Pie
  include MiniMagickHelper

  BORDER = 1
  SWEEP_POSITIVE = 1

  def initialize(data, width, height)
    @data = data
    @width = (width || 120).to_i
    @height = (height || 120).to_i
    @radius = @width / 2 - BORDER
    @half_height = @height / 2
    @half_width = @width / 2
  end

  def render
    new_image do |convert|
      convert.size "#{@width}x#{@height}"
      convert << 'xc:white'
      convert.stroke 'black'
      convert.strokewidth '0.5'
      convert.format 'PNG8'
      draw_chart(convert)
    end
  end

  private

  def draw_chart(convert)
    start_angle = 0.0
    @data.each do |language|
      convert.fill "##{language[:color]}"
      degrees = language_degrees(language[:percent])
      next if degrees.zero?
      end_angle = start_angle + degrees
      convert.draw wedge(start_angle, end_angle)
      start_angle = end_angle
    end
  end

  def language_degrees(percentage)
    degrees = percentage.to_f / 100 * 360.0
    degrees >= 360.0 ? 359.9999 : degrees
  end

  def rad_from_degree(degree)
    rotated_to_rad = (270 + degree) % 360
    rotated_to_rad / 180.0 * Math::PI
  end

  def wedge(angle0, angle1)
    rad0 = rad_from_degree(angle0)
    rad1 = rad_from_degree(angle1)

    dx0 = x_value(rad0)
    dx1 = x_value(rad1)
    dy0 = y_value(rad0)
    dy1 = y_value(rad1)
    "path 'M#{@half_width},#{@half_width} l#{dx0},#{dy0} A#{@radius},#{@radius} "\
    "0 #{arc_scale(angle0, angle1)},#{SWEEP_POSITIVE} #{dx1 + @half_width},#{(dy1 + @half_height)} z'"
  end

  def arc_scale(angle0, angle1)
    angle1 - angle0 > 180 ? 1 : 0
  end

  def x_value(radians)
    @radius * Math.cos(radians)
  end

  def y_value(radians)
    @radius * Math.sin(radians)
  end
end
