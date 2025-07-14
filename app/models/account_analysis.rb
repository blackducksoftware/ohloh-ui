# frozen_string_literal: true

class AccountAnalysis < ApplicationRecord
  self.table_name = 'vitae'
  belongs_to :account, optional: true
  has_one :account_analysis_fact, foreign_key: :vita_id
  has_many :account_analysis_language_facts, foreign_key: :vita_id
  has_one :name_fact, foreign_key: :vita_id

  def account_analysis_fact
    name_fact || NilAccountAnalysisFact.new
  end

  def language_logos
    facts = account_analysis_language_facts.with_language_and_projects
    logo_ids = facts.joins(:most_commits_project).pluck('projects.logo_id') +
               facts.joins(:recent_commit_project).pluck('projects.logo_id')
    Logo.where(id: logo_ids.compact)
  end

  def self.ransackable_attributes(_auth_object = nil)
    authorizable_ransackable_attributes
  end

  def self.ransackable_associations(_auth_object = nil)
    authorizable_ransackable_associations
  end
end
