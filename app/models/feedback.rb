class Feedback < ActiveRecord::Base
  belongs_to :project
  attr_accessor :count, :interested, :logo

  def self.interested(project_id)
    total = Feedback.where(project_id: project_id).count.to_f
    interested = Feedback.where(project_id: project_id, more_info: 1).count.to_f
    ((interested / total) * 100).to_i.to_s + '%'
  end

  def self.rating_scale(project_id)
    total = Feedback.where(project_id: project_id).count.to_f
    arr = []
    1.upto(5) do |x|
      count = Feedback.where(project_id: project_id, rating: x).count.to_f
      percent = ((count / total) * 100).to_i
      arr << [count.to_i, percent]
    end
    arr
  end
end
