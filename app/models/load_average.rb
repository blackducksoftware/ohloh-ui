# frozen_string_literal: true

class LoadAverage < ActiveRecord::Base
  def too_high?
    (current.to_f > max.to_f)
  end
end
