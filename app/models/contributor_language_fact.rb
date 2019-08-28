# frozen_string_literal: true

class ContributorLanguageFact < NameLanguageFact
  belongs_to :analysis
  belongs_to :name
end
