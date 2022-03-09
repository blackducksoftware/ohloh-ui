# frozen_string_literal: true

class ActivityFact < ApplicationRecord
  belongs_to :name, optional: true
  belongs_to :language, optional: true
  belongs_to :analysis, optional: true
end
