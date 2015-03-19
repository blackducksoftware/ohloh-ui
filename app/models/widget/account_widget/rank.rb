class AccountWidget::Rank < AccountWidget
  def width
    32
  end

  def height
    24
  end

  def image
    format = 'png'
    image = Magick::Image.read('/icons/sm_laurel_#{rank}.#{format}')
    image[0].to_blob { |info| info.format = format }
  end

  def position
    2
  end
end
