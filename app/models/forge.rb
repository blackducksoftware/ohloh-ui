class Forge < ActiveRecord::Base
  has_many :repositories
  has_many :projects

  def match(_)
    raise 'You must override match(url) in each Forge subclass.'
  end

  def json_api_url(_)
    nil
  end

  def get_project_attributes(_)
    {}
  end

  def get_code_location_attributes(_)
    []
  end
end
