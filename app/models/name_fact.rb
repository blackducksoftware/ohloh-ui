class NameFact < ActiveRecord::Base
  include Comparable

  belongs_to :name
  has_one :project, -> { where { deleted.not_eq(true) } }, foreign_key: :best_analysis_id, primary_key: :analysis_id

  def <=>(other)
    return -1 if other.nil?
    other.last_checkin <=> last_checkin
  end
end
