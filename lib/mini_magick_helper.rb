# frozen_string_literal: true

module MiniMagickHelper
  private

  def new_image
    tempfile = Tempfile.new(['image-base-', '.png'])

    MiniMagick::Tool.new('convert') do |convert|
      yield convert
      convert << tempfile.path
    end

    image = MiniMagick::Image.open(tempfile.path)
    tempfile.close
    image
  end
end
