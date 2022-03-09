# frozen_string_literal: true

class Forge < ApplicationRecord
  self.primary_key = :id
  has_many :repositories
  has_many :projects

  def match(_url)
    raise 'You must override match(url) in each Forge subclass.'
  end

  def json_api_url(_match)
    nil
  end

  def get_project_attributes(_match)
    {}
  end

  def get_code_location_attributes(_match)
    []
  end
end
