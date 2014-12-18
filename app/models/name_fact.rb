class NameFact < ActiveRecord::Base
  include Comparable

  belongs_to :name

  def <=>(other)
    return -1 if other.nil?
    other.last_checkin <=> last_checkin
  end
end
