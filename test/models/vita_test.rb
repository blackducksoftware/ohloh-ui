require 'test_helper'

class VitaTest < ActiveSupport::TestCase
  let(:vita) { create(:vita) }
  let(:vita_with_fact) { create(:best_vita) }
  let(:logo) { create(:attachment) }
  let(:project) { create(:project) }

  describe 'vita_fact' do
    it 'should return nil_vita_fact when there is not vita_fact' do
      vita.vita_fact.class.must_equal NilVitaFact
    end

    it 'should return vita_fact when there is vita_fact' do
      vita_with_fact.vita_fact.class.must_equal VitaFact
    end
  end

  describe 'language_logos' do
    it 'should return logos of projects with recent commit and most commits for lang facts' do
    lang1 = create(:language, category: 0)
    lang2 = create(:language, category: 1)
    fact1 = create(:vita_language_fact, language: lang1, most_commits: 600)
    fact2 = create(:vita_language_fact, language: lang2, total_activity_lines: 20, most_commits: 100)

    language_facts = VitaLanguageFact.where.not(id: nil)
    vita.stubs(:vita_language_facts).returns(language_facts)
    VitaLanguageFact.any_instance.stubs(:most_commits_project).returns(project)
    VitaLanguageFact.any_instance.stubs(:recent_commit_project).returns(project)
    Project.any_instance.stubs(:logo_id).returns(logo.id)
    vita.language_logos.first.must_equal Logo.where(id: logo.id).first
    end
  end
end
