class Project < ActiveRecord::Base
  has_one :permission, as: :target

  def to_param
    url_name
  end

  def active_managers
    Manage.for_project(self).active.to_a
  end
end
