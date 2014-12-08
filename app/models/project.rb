class Project < ActiveRecord::Base
  has_one :permission, as: :target

  def to_param
    url_name
  end
end
