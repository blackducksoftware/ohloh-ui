# frozen_string_literal: true

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

      language_facts = VitaLanguageFact.where(id: [fact2.id, fact1.id])
      vita.stubs(:vita_language_facts).returns(language_facts)

      logo_id1 = fact1.most_commits_project.logo_id
      logo_id2 = fact1.recent_commit_project.logo_id
      logo_id3 = fact2.most_commits_project.logo_id
      logo_id4 = fact2.recent_commit_project.logo_id

      vita.language_logos.must_include Logo.where(id: logo_id1).first
      vita.language_logos.must_include Logo.where(id: logo_id2).first
      vita.language_logos.must_include Logo.where(id: logo_id3).first
      vita.language_logos.must_include Logo.where(id: logo_id4).first
    end
  end
end
