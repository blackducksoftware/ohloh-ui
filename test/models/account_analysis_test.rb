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

    it 'should handle case when name_fact is nil' do
      account_analysis.stubs(:name_fact).returns(nil)
      _(account_analysis.account_analysis_fact.class).must_equal NilAccountAnalysisFact
    end

    it 'should return the actual name_fact when present' do
      name_fact = create(:name_fact, vita_id: account_analysis.id)
      account_analysis.stubs(:name_fact).returns(name_fact)
      _(account_analysis.account_analysis_fact).must_equal name_fact
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

    it 'should return empty collection when no language facts exist' do
      account_analysis.stubs(:account_analysis_language_facts).returns(AccountAnalysisLanguageFact.none)
      _(account_analysis.language_logos.to_a).must_be_empty
    end

    it 'should handle nil logo_ids gracefully' do
      lang1 = create(:language, category: 0)
      project_without_logo = create(:project, logo_id: nil)
      fact1 = create(:account_analysis_language_fact,
                     language: lang1,
                     most_commits_project: project_without_logo,
                     recent_commit_project: project_without_logo)

      language_facts = AccountAnalysisLanguageFact.where(id: fact1.id)
      account_analysis.stubs(:account_analysis_language_facts).returns(language_facts)

      # Should not raise error and should return empty collection
      _(account_analysis.language_logos.to_a).must_be_empty
    end
  end

  describe 'associations' do
    it 'should belong to account' do
      account = create(:account)
      account_analysis = create(:account_analysis, account: account)
      _(account_analysis.account).must_equal account
    end

    it 'should have one account_analysis_fact through name_fact' do
      account_analysis = create(:account_analysis)
      name_fact = create(:name_fact, vita_id: account_analysis.id)
      _(account_analysis.name_fact).must_equal name_fact
    end

    it 'should have many account_analysis_language_facts' do
      account_analysis = create(:account_analysis)
      fact1 = create(:account_analysis_language_fact, vita_id: account_analysis.id)
      fact2 = create(:account_analysis_language_fact, vita_id: account_analysis.id)

      _(account_analysis.account_analysis_language_facts).must_include fact1
      _(account_analysis.account_analysis_language_facts).must_include fact2
    end
  end

  describe 'table_name' do
    it 'should use vitae as table name' do
      _(AccountAnalysis.table_name).must_equal 'vitae'
    end
  end

  describe 'ransack configuration' do
    it 'should have ransackable_attributes method' do
      _(AccountAnalysis).must_respond_to :ransackable_attributes
    end

    it 'should have ransackable_associations method' do
      _(AccountAnalysis).must_respond_to :ransackable_associations
    end

    it 'should call authorizable_ransackable_attributes for attributes' do
      AccountAnalysis.expects(:authorizable_ransackable_attributes).returns(%w[id account_id])
      _(AccountAnalysis.ransackable_attributes).must_equal %w[id account_id]
    end

    it 'should call authorizable_ransackable_associations for associations' do
      AccountAnalysis.expects(:authorizable_ransackable_associations).returns(%w[account name_fact])
      _(AccountAnalysis.ransackable_associations).must_equal %w[account name_fact]
    end
  end
end
