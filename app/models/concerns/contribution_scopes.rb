module ContributionScopes
  extend ActiveSupport::Concern

  included do
    scope :sort_by_name, -> { order('LOWER(people.effective_name)') }
    scope :sort_by_kudo_position, -> { order('people.kudo_position NULLS LAST') }
    scope :sort_by_commits, -> { order('name_facts.commits DESC NULLS LAST') }
    scope :sort_by_twelve_month_commits, -> { order('name_facts.twelve_month_commits DESC NULLS LAST') }
    scope :sort_by_language, -> { order('lower(languages.nice_name) NULLS LAST, name_facts.commits DESC NULLS LAST') }
    scope :sort_by_latest_commit, -> { order('name_facts.last_checkin DESC NULLS LAST') }
    scope :sort_by_newest, -> { order('name_facts.first_checkin DESC NULLS LAST') }
    scope :sort_by_oldest, -> { order('name_facts.first_checkin NULLS FIRST') }
    scope :last_30_days, ->(logged_at) { where('name_facts.last_checkin > ?', logged_at - 30.days) }
    scope :last_year, ->(logged_at) { where('name_facts.last_checkin > ?', logged_at - 12.months) }
    scope :within_timespan, lambda { |time_span, logged_at|
      return unless logged_at && TIME_SPANS.keys.include?(time_span)
      send(TIME_SPANS[time_span], logged_at)
    }
  end
end
