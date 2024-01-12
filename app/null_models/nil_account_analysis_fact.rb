# frozen_string_literal: true

class NilAccountAnalysisFact < NullObject
  attr_reader :first_checkin, :last_checkin

  empty_methods :commits_by_language, :commits_by_project, :name_language_facts
  nought_methods :commits, :thirty_day_commits, :twelve_month_commits
end
