class ProjectSecuritySet < ActiveRecord::Base
  belongs_to :project
  has_many :releases

  def most_recent_releases
    releases.order(released_on: :asc).last(10)
  end
end
