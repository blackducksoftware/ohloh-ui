# frozen_string_literal: true

class NilContributorFact < NullObject
  attr_reader :name_id, :first_checkin, :last_checkin

  empty_methods :name_language_facts
  nought_methods :twelve_month_commits, :commits, :analysis_id, :primary_language_id, :comment_ratio, :man_months

  def primary_language
    NilLanguage.new
  end

  def name
    NilName.new
  end
end
