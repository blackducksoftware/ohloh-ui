# frozen_string_literal: true

require 'test_helper'

class AnalysisSummaryTest < ActiveSupport::TestCase
  describe 'recent_contribution_persons' do
    let(:analysis) { create(:analysis) }
    let(:analysis_summary) { AnalysisSummary.new(analysis: analysis) }
    let(:person) { create(:person, project: analysis.project) }

    it 'must return people matching recent_contributors' do
      analysis_summary.stubs(:recent_contributors).returns([person.id])

      analysis_summary.recent_contribution_persons.must_equal [person]
    end

    it 'must return people matching the name_ids in recent_contributors' do
      account = create(:account)
      person.update!(account: account)
      name2 = create(:name)
      analysis_summary.stubs(:recent_contributors).returns(['name_ids', name2.id, person.name.id])
      analysis_summary.recent_contribution_persons.must_equal [person]
    end
  end
end
