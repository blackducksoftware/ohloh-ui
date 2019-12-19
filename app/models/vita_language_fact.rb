# frozen_string_literal: true

class VitaLanguageFact < NameLanguageFact
  belongs_to :vita
  belongs_to :language
  belongs_to :most_commits_project, class_name: 'Project'
  belongs_to :recent_commit_project, class_name: 'Project'

  scope :ordered, lambda {
    joins(:language)
      .order('category, total_months desc, total_commits desc, total_activity_lines desc')
  }

  scope :with_language_and_projects, lambda {
    includes(%i[language most_commits_project recent_commit_project])
      .order('most_commits DESC')
  }
end
