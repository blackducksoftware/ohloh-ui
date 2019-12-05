# frozen_string_literal: true

# FDW: called by app/admin. #unused.
class LoadAverage < ActiveRecord::Base
  def too_high?
    (current.to_f > max.to_f)
  end
end
