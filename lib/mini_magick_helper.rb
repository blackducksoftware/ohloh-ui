module MiniMagickHelper
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

