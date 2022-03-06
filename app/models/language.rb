# frozen_string_literal: true

class Language < ApplicationRecord
  serialize :active_contributors, Array
  serialize :experienced_contributors, Array

  scope :by_name, -> { order('lower(name)') }
  scope :by_nice_name, -> { order('lower(nice_name)') }
  scope :by_total, -> { order('(code + comments + blanks) desc').by_name }
  scope :by_code, -> { order(code: :desc).by_name }
  scope :by_comment_ratio, -> { order(avg_percent_comments: :desc).by_name }
  scope :by_projects, -> { order(projects: :desc).by_name }
  scope :by_contributors, -> { order(contributors: :desc).by_name }
  scope :by_commits, -> { order(commits: :desc).by_name }
  scope :from_param, ->(param) { where(Language.arel_table[:name].eq(param).or(Language.arel_table[:id].eq(param))) }

  filterable_by ['languages.nice_name']
  ALL_LANGUAGES = ['All Languages', ''].freeze
  DEFAULT_LANGUAGES = %w[c html java php].freeze

  class << self
    def new_languages_for_project(project, days)
      new_languages_collection = project.commit_flags.new_languages.where(['commit_flags.time > ?', days]).to_a
      new_languages_collection.sort_by(&:time).group_by(&:data)
    end

    def map
      Language.order(arel_table[:nice_name].lower).each_with_object([]) do |language, array|
        array << [language.nice_name, language.name]
      end.unshift(ALL_LANGUAGES)
    end
  end

  def total
    code.to_i + comments.to_i + blanks.to_i
  end

  def to_param
    name
  end

  def preload_active_and_experienced_accounts
    active_account_ids = active_contributors.map(&:first)
    experienced_account_ids = experienced_contributors.map(&:first)
    Account.where(id: (active_account_ids + experienced_account_ids)).includes(:person).group_by(&:id)
  end
end
