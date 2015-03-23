class Factoid < ActiveRecord::Base
  belongs_to :analysis
  belongs_to :language
  belongs_to :license

  delegate :project, to: :analysis

  def human_rating
    case severity
    when 1..100 then 'icon-ok-sign good'
    when 0 then 'icon-info-sign info'
    when -2..-1 then 'icon-warning-sign warning'
    when -100..-3 then 'icon-exclamation-sign bad'
    else fail 'weird severity'
    end
  end
end
