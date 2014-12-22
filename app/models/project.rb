class Project < ActiveRecord::Base
  has_one :permission, as: :target
  belongs_to :logo

  has_many :manages, -> { where(deleted_at: nil, deleted_by: nil) }, as: 'target'
  has_many :managers, through: :manages, source: :account
  has_many :reviews

  def to_param
    url_name
  end

  def active_managers
    Manage.projects.for_target(self).active.to_a.map(&:account)
  end
end
