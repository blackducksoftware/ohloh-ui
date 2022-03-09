# frozen_string_literal: true

class LanguageExperience < ApplicationRecord
  belongs_to :position, optional: true
  belongs_to :language, optional: true

  validates :language, presence: true
end
