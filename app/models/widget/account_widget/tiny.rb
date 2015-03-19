class AccountWidget::Tiny < AccountWidget
  def height
    15
  end

  def width
    80
  end

  def image
    image = Magick::Image.read("#{File.dirname(__FILE__)}/../../public/images/widget_logos/Profile_tiny.png")
    image[0].to_blob { |info| info.format = 'gif'; }
  end

  def position
    3
  end
end
