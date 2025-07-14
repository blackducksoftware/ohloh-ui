# frozen_string_literal: true

class Widget::AccountWidget::Rank < Widget::AccountWidget
  def width
    32
  end

  def height
    24
  end

  def image
    file_path = Rails.root.join("app/assets/images/icons/sm_laurel_#{rank}.png")
    File.binread(file_path)
  end

  def position
    2
  end
end
