class Setting < ActiveRecord::Base
  class << self
    def get_value(key)
      where(key: key).pluck(:value).first
    end
  end
end
