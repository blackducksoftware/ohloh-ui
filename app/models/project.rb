class Project < ActiveRecord::Base
  has_one :permission, as: :target
  belongs_to :logo

  def to_param
    url_name
  end

  def active_managers
    Manage.for_project(self).active.to_a
  end
end
