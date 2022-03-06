# frozen_string_literal: true

class Factoid < ApplicationRecord
  belongs_to :analysis, optional: true
  belongs_to :language, optional: true
  belongs_to :license, optional: true

  delegate :project, to: :analysis
end
