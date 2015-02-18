class Vita < ActiveRecord::Base
  self.table_name = 'vitae'
  belongs_to :account
  has_one :vita_fact
  has_many :vita_language_facts

  def vita_fact
    VitaFact.where(vita_id: id).first || NilVitaFact.new
  end

  def language_logos
    facts = vita_language_facts.with_languages_and_commits
    projects = facts.map(&:most_commits_project) + facts.map(&:recent_commit_project)
    logo_ids = projects.compact.map(&:logo_id).compact
    Logo.where(id: logo_ids)
  end
end
