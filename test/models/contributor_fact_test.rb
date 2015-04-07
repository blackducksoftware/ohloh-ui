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

  describe '#first_for_name_id_and_project_id' do
    it 'must return contributor_fact' do
      proj = create(:project)
      cf = create(:name_fact, type: 'ContributorFact', analysis: proj.best_analysis)
      create(:analysis_alias, analysis: cf.analysis, commit_name: cf.name, preferred_name: cf.name)
      retval = ContributorFact.first_for_name_id_and_project_id(cf.name.id, cf.analysis.project.id)
      retval.id.must_equal cf.id
    end
  end

  describe '#name_language_facts' do
    it 'must return langauge facts' do
      analysis = create(:analysis)
      name = create(:name)
      contributor_fact = create(:contributor_fact, analysis_id: analysis.id, name_id: name.id)
      lang = create(:language)
      fact = create(:vita_language_fact, language: lang, analysis_id: analysis.id, name_id: name.id)

      contributor_fact.name_language_facts.must_equal [fact]
    end
  end
end
