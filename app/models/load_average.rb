# frozen_string_literal: true

class LoadAverage < ApplicationRecord
  def too_high?
    (current.to_f > max.to_f)
  end
end
