# Creates an array of 4 contributions and returns that
# If "my_person" is provided, creates contributions for that person
# Otherwise, creates a new person for each contribution
def create_contributions(project, my_person = nil)
  Analysis.any_instance.stubs(:logged_at).returns(Date.today)
  contributions = []
  [1.day.ago, 2.day.ago, 2.month.ago, 2.years.ago].each do |date|
    #person = create(:person, project: project)
    person = (my_person ? my_person : create(:person, project: project)
    contribution = person.contributions.first
    contribution.contributor_fact.update_columns(analysis_id: project.best_analysis_id, last_checkin: date)
    contributions << contribution
  end
  contributions
end
