# frozen_string_literal: true

require 'test_helper'

class ContributorFactTest < ActiveSupport::TestCase
  let(:commit)  { create(:commit) }
  let(:project) { create(:project) }
  let(:analysis) { project.best_analysis }
  let(:name_object) { create(:name) }
  let(:sloc_set) { create(:sloc_set, code_set_id: commit.code_set_id) }
  let(:analysis_sloc_set) { create(:analysis_sloc_set, sloc_set_id: sloc_set.id, analysis_id: analysis.id, as_of: 2) }
  let(:analysis_alias) do
    create(:analysis_alias, commit_name: commit.name, analysis_id: analysis.id, preferred_name_id: name_object.id)
  end
  let(:contributor_fact) do
    create(:contributor_fact, analysis_id: analysis_sloc_set.analysis_id, name_id: analysis_alias.preferred_name_id)
  end

  describe '#unclaimed_for_project' do
    it 'must return contributor_facts which have no matching position' do
      project.editor_account = create(:admin)
      project.update!(best_analysis_id: analysis.id)

      ContributorFact.where(analysis_id: analysis).destroy_all
      contributor_fact = create(:contributor_fact, analysis_id: analysis.id)

      ContributorFact.unclaimed_for_project(project).to_a.map(&:id).must_equal [contributor_fact.id]
    end
  end

  describe '#first_for_name_id_and_project_id' do
    it 'must return contributor_fact' do
      cf = create(:name_fact, type: 'ContributorFact', analysis: project.best_analysis)
      create(:analysis_alias, analysis: cf.analysis, commit_name: cf.name, preferred_name: cf.name)
      retval = ContributorFact.first_for_name_id_and_project_id(cf.name.id, cf.analysis.project.id)
      retval.id.must_equal cf.id
    end
  end

  describe '#name_language_facts' do
    it 'must return langauge facts' do
      lang = create(:language)
      fact = create(:account_analysis_language_fact, language: lang, analysis_id: analysis.id, name_id: name_object.id)

      contributor_fact.name_language_facts.must_equal [fact]
    end
  end

  describe 'person' do
    it 'should' do
      person = create(:person, name_id: name_object.id, project_id: analysis.project_id)
      contributor_fact.reload.person.must_equal person
    end
  end

  describe 'kudo_rank' do
    it 'should return kudo_rank' do
      _person = create(:person, name_id: name_object.id, project_id: analysis.project_id)
      assert_nil contributor_fact.kudo_rank
    end
  end

  describe 'monthly_commits' do
    let(:other_contributor_fact) { create(:contributor_fact, analysis: create(:analysis)) }

    before { create(:commit, name_id: contributor_fact.name_id) }

    it 'should return contributor monthly commits' do
      contributor_fact.monthly_commits.wont_be_empty
    end

    it 'should return different monthly commits for different contributors' do
      other_contributor_fact.monthly_commits.wont_equal contributor_fact.monthly_commits
    end
  end
end
