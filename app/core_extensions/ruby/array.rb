# frozen_string_literal: true

class Array
  def exclude(*values)
    self - values
  end
end
