class AccountWidget::Tiny < AccountWidget
  def height
    15
  end

  def width
    80
  end

  def image
    file_path = Rails.root.join('app', 'assets', 'images', 'widget_logos', 'profile_tiny.png')
    MiniMagick::Image.read(file_path).to_blob
  end

  def position
    3
  end
end
