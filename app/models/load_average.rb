class LoadAverage < ActiveRecord::Base
  def self.too_high?
    l = LoadAverage.first
    l && l.too_high?
  end

  def too_high?
    (self.current.to_f > self.max.to_f)
  end
end
