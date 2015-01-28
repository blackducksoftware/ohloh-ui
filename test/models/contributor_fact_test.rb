require 'test_helper'

class ContributorFactTest < ActiveSupport::TestCase
  describe '#unclaimed_for_project' do
    it 'must return contributor_facts which have no matching position' do
      project = projects(:linux)
      analysis = analyses(:linux)
      project.editor_account = create(:admin)
      project.update!(best_analysis_id: analysis.id)

      ContributorFact.where(analysis_id: analysis).destroy_all
      contributor_fact = create(:contributor_fact, analysis_id: analysis.id)

      ContributorFact.unclaimed_for_project(project).to_a.map(&:id).must_equal [contributor_fact.id]
    end
  end
end
