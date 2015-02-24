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
    logo_ids = facts.joins(:most_commits_project).pluck(:logo_id) +
               facts.joins(:recent_commit_project).pluck(:logo_id)
    Logo.where(id: logo_ids.compact)
  end
end
