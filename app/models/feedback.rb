# frozen_string_literal: true

class Feedback < ActiveRecord::Base
  belongs_to :project
  before_create :set_project_id
  attr_accessor :count, :interested, :logo, :project_name

  class << self
    def interested(project_id)
      total = Feedback.where(project_id: project_id).count.to_f
      interested = Feedback.where(project_id: project_id, more_info: 1).count.to_f
      ((interested / total) * 100).to_i.to_s + '%'
    end

    def rating_scale(project_id)
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

  private

  def set_project_id
    return true if project_id.present?

    self.project_id = Project.find_by(name: project_name).try(:id)
  end
end
