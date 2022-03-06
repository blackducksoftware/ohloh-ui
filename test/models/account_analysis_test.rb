# frozen_string_literal: true

require 'test_helper'

class AccountAnalysisTest < ActiveSupport::TestCase
  let(:account_analysis) { create(:account_analysis) }
  let(:account_analysis_with_fact) { create(:best_account_analysis) }
  let(:logo) { create(:attachment) }
  let(:project) { create(:project) }

  describe 'account_analysis_fact' do
    it 'should return nil_account_analysis_fact when there is not account_analysis_fact' do
      _(account_analysis.account_analysis_fact.class).must_equal NilAccountAnalysisFact
    end

    it 'should return account_analysis_fact when there is account_analysis_fact' do
      _(account_analysis_with_fact.account_analysis_fact.class).must_equal AccountAnalysisFact
    end
  end

  describe 'language_logos' do
    it 'should return logos of projects with recent commit and most commits for lang facts' do
      lang1 = create(:language, category: 0)
      lang2 = create(:language, category: 1)
      fact1 = create(:account_analysis_language_fact, language: lang1, most_commits: 600)
      fact2 = create(:account_analysis_language_fact, language: lang2, total_activity_lines: 20, most_commits: 100)

      language_facts = AccountAnalysisLanguageFact.where(id: [fact2.id, fact1.id])
      account_analysis.stubs(:account_analysis_language_facts).returns(language_facts)

      logo_id1 = fact1.most_commits_project.logo_id
      logo_id2 = fact1.recent_commit_project.logo_id
      logo_id3 = fact2.most_commits_project.logo_id
      logo_id4 = fact2.recent_commit_project.logo_id

      _(account_analysis.language_logos).must_include Logo.where(id: logo_id1).first
      _(account_analysis.language_logos).must_include Logo.where(id: logo_id2).first
      _(account_analysis.language_logos).must_include Logo.where(id: logo_id3).first
      _(account_analysis.language_logos).must_include Logo.where(id: logo_id4).first
    end
  end
end
