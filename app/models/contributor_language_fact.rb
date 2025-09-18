# frozen_string_literal: true

# :nocov:
class ContributorLanguageFact < NameLanguageFact
  belongs_to :analysis, optional: true
  belongs_to :name, optional: true
end
# :nocov:
