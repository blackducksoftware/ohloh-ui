# frozen_string_literal: true

class NameLanguageFact < ApplicationRecord
  belongs_to :language, optional: true
end
