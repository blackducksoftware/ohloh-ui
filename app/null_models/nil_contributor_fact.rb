# frozen_string_literal: true

class NilContributorFact < NullObject
  attr_reader :name_id, :first_checkin, :last_checkin

  nought_methods :twelve_month_commits, :commits, :analysis_id, :primary_language_id, :comment_ratio, :man_months

  def primary_language
    NilLanguage.new
  end

  def name_language_facts
    []
  end

  def name
    NilName.new
  end
end
