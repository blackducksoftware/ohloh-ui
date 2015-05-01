class Chart::Pie
  include MiniMagickHelper

  BORDER = 1
  SWEEP_POSITIVE = 1

  def initialize(data, width, height)
    @data = data
    @width = width
    @height = height
    @radius = @width / 2 - BORDER
  end

  def render
    start_angle = 0.0
    image do |convert|
      @data.each do |lang, detail|
        convert.fill "##{detail[:color]}"
        degrees = detail[:percent].to_f / 100 * 360.0
        degrees = 359.9999 if degrees >= 360.0
        next if degrees == 0
        end_angle = start_angle + degrees
        draw.path wedge(start_angle, end_angle)
        start_angle = end_angle
      end
    end

    draw.draw(canvas)
    canvas.to_blob
  end

  private

  def image
    new_image do |convert|
      convert.size "#{@width}x#{@height}"
      convert << 'xc:white'
      convert.stroke 'black'
      convert.stroke_width 0.5
      convert.format 'PNG8'
      yield convert
    end
  end

  def rad_from_degree(degree)
    rotated_to_rad = (270 + degree) % 360
    rotated_to_rad / 180.0 * Math::PI
  end

  def wedge(angle0, angle1)
    rad0 = rad_from_degree(angle0)
    rad1 = rad_from_degree(angle1)

    dx0 = @radius * Math.cos(rad0)
    dy0 = @radius * Math.sin(rad0)
    dx1 = @radius * Math.cos(rad1)
    dy1 = @radius * Math.sin(rad1)
    large_arc = (angle1 - angle0 > 180) ? 1 : 0

    "M#{@width},#{@height} l#{dx0},#{dy0} A#{@radius},#{@radius} 0 #{large_arc},#{SWEEP_POSITIVE} #{dx1 + @width},#{(dy1 + @height)} z"
  end
end
