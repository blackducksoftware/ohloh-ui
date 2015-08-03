class LoadAverage < ActiveRecord::Base
  class << self
    def too_high?
      l = LoadAverage.first
      l && l.too_high?
    end
  end

  def too_high?
    (current.to_f > max.to_f)
  end
end
