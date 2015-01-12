require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  it '#first_review_for' do
    account = accounts(:user)
    project = projects(:linux)
    review = Review.create!(account_id: account.id, project_id: project.id)

    project.first_review_for(account).must_equal review
  end

  describe '#unclaimed_contributor_facts' do
    it 'must return contributor_facts which have no matching position' do
      project = projects(:linux)
      analysis = analyses(:linux)
      project.editor_account = accounts(:admin)
      project.update!(best_analysis_id: analysis.id)

      ContributorFact.where(analysis_id: analysis).destroy_all
      contributor_fact = create(:contributor_fact, analysis_id: analysis.id)

      project.unclaimed_contributor_facts.must_equal [contributor_fact]
    end
  end
end
