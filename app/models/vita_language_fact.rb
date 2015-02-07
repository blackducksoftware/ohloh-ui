class VitaLanguageFact < NameLanguageFact
  belongs_to :vita
  belongs_to :language

  scope :ordered, -> {
    joins(:language)
    .order('category, total_months desc, total_commits desc, total_activity_lines desc')
  }
end
