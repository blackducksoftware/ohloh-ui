class NilContributorFact < NullObject
  attr_reader :name_id, :first_checkin, :last_checkin
  nought_methods :twelve_month_commits, :commits

  def primary_language
    NilLanguage.new
  end

  def name_language_facts
    []
  end
end
