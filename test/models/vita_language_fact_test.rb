# frozen_string_literal: true

require 'test_helper'

class VitaLanguageFactTest < ActiveSupport::TestCase
  let(:lang1) { create(:language, category: 0) }
  let(:lang2) { create(:language, category: 0) }
  let(:lang3) { create(:language, category: 1) }
  let(:lang4) { create(:language, category: 1) }
  let(:lang5) { create(:language, category: 2) }
  let(:lang6) { create(:language, category: 2) }
  let(:fact1) { create(:vita_language_fact, language: lang1, most_commits: 600) }
  let(:fact2) { create(:vita_language_fact, language: lang2, total_activity_lines: 20, most_commits: 100) }
  let(:fact3) { create(:vita_language_fact, language: lang3, total_commits: 100, most_commits: 200) }
  let(:fact4) { create(:vita_language_fact, language: lang4, total_activity_lines: 100, most_commits: 300) }
  let(:fact5) { create(:vita_language_fact, language: lang5, total_commits: 100, most_commits: 400) }
  let(:fact6) { create(:vita_language_fact, language: lang6, total_months: 50, most_commits: 500) }

  describe 'ordered' do
    it 'should return ordered results' do
      result = [fact2.id, fact1.id, fact3.id, fact4.id, fact6.id, fact5.id]
      ordered_facts = VitaLanguageFact.where.not(language_id: nil).ordered
      ordered_facts.map(&:id).must_equal result
    end
  end

  describe 'with_language_and_projects' do
    it 'should return ordered by most commits' do
      result = [fact1.id, fact6.id, fact5.id, fact4.id, fact3.id, fact2.id]
      ordered_facts = VitaLanguageFact.where.not(language_id: nil).with_language_and_projects
      ordered_facts.map(&:id).must_equal result
    end
  end
end
