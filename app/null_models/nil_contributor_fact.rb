class NilContributorFact < NullObject
  attr_reader :name_id, :primary_language, :first_checkin, :last_checkin
  nought_methods :twelve_month_commits, :commits
end
