# frozen_string_literal: true

def create_contributions(project)
  Analysis.any_instance.stubs(:oldest_code_set_time).returns(Date.current)
  contributions = []
  [1.day.ago, 2.days.ago, 2.months.ago, 2.years.ago].each do |date|
    person = create(:person, project: project)
    contribution = person.contributions.first
    contribution.contributor_fact.update_columns(analysis_id: project.best_analysis_id, last_checkin: date)
    contributions << contribution
  end
  contributions
end
