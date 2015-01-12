class Rating < ActiveRecord::Base
  belongs_to :account
  belongs_to :project

  validates :score, numericality: { only_integer: true },
                    inclusion: { in: [1, 2, 3, 4, 5] }

  after_save :update_project_rating_average
  after_destroy :update_project_rating_average

  private

  def update_project_rating_average
    project.editor_account = account
    project.update_attributes rating_average: project.ratings.average(:score)
  end
end
