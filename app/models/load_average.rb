class LoadAverage < ActiveRecord::Base
  class << self
    def too_high?
      LoadAverage.first.try(:too_high?)
    end
  end

  protected

  def too_high?
    (current.to_f > max.to_f)
  end
end
