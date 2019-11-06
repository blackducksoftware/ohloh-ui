# frozen_string_literal: true

# rubocop:disable HasManyOrHasOneDependent

class Vita < ActiveRecord::Base
  self.table_name = 'vitae'
  belongs_to :account
  has_one :vita_fact
  has_many :vita_language_facts
  has_one :name_fact

  def vita_fact
    name_fact || NilVitaFact.new
  end

  def language_logos
    facts = vita_language_facts.with_language_and_projects
    logo_ids = facts.joins(:most_commits_project).pluck(:logo_id) +
               facts.joins(:recent_commit_project).pluck(:logo_id)
    Logo.where(id: logo_ids.compact)
  end
end

# rubocop:enable HasManyOrHasOneDependent
