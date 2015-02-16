class VitaLanguageFact < NameLanguageFact
  belongs_to :vita
  belongs_to :language

  scope :ordered, lambda {
    joins(:language)
      .order('category, total_months desc, total_commits desc, total_activity_lines desc')
  }

  scope :with_languages_and_commits, lambda {
    includes([:language, :most_commits_project, :recent_commit_project])
      .order('most_commits DESC').references(:all)
  }

  class << self
    def logos
      facts = with_languages_and_commits
      projects = facts.map(&:most_commits_project) + facts.map(&:recent_commit_project)
      logo_ids = projects.compact.map(&:logo_id).compact
      Logo.where(id: logo_ids)
    end
  end
end
