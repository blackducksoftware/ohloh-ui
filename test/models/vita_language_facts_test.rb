require 'test_helper'

class VitaLanguageFactTest < ActiveSupport::TestCase
  describe 'ordered' do
    it 'should return ordered results' do
      lang1 = create(:language, category: 0)
      lang2 = create(:language, category: 0)
      lang3 = create(:language, category: 1)
      lang4 = create(:language, category: 1)
      lang5 = create(:language, category: 2)
      lang6 = create(:language, category: 2)
      fact1 = create(:vita_language_fact, language: lang1)
      fact2 = create(:vita_language_fact, language: lang2, total_activity_lines: 20)
      fact3 = create(:vita_language_fact, language: lang3, total_commits: 100)
      fact4 = create(:vita_language_fact, language: lang4, total_activity_lines: 100)
      fact5 = create(:vita_language_fact, language: lang5, total_commits: 100)
      fact6 = create(:vita_language_fact, language: lang6, total_months: 50)

      ordered_facts = VitaLanguageFact.where.not(language_id: nil).ordered
      ordered_facts.map(&:id).must_equal [fact2.id, fact1.id, fact3.id, fact4.id, fact6.id, fact5.id]
    end
  end
end
