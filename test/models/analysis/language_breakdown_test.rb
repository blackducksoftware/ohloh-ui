require 'test_helper'

class Analysis::LanguageBreakdownTest < ActiveSupport::TestCase
  describe 'collection' do
    let(:activity_fact) do
      create(:activity_fact, code_added: 5, code_removed: 3, comments_added: 3, comments_removed: 0)
    end

    before do
      create(:activity_fact, analysis: activity_fact.analysis, code_added: 6, code_removed: 5,
                             comments_added: 5, comments_removed: 4)
    end

    it 'must group results by language' do
      ActivityFact.last.update!(language: activity_fact.language)
      results = Analysis::LanguageBreakdown.new(analysis: activity_fact.analysis).collection

      results.length.must_equal 1
      results.first.code_total.must_equal 3
      results.first.comments_total.must_equal 4
    end

    it 'must not return activity_facts with zero code or comment totals' do
      activity_fact.update! code_added: 5, code_removed: 5,
                            comments_added: 5, comments_removed: 5
      ActivityFact.last.update! code_added: 5, code_removed: 5,
                                comments_added: 5, comments_removed: 5

      results = Analysis::LanguageBreakdown.new(analysis: activity_fact.analysis).collection
      results.must_be :empty?
    end

    it 'must return code added or removed details' do
      results = Analysis::LanguageBreakdown.new(analysis: activity_fact.analysis).collection

      results.length.must_equal 2
      results.first.code_total.must_equal 2
      results.last.code_total.must_equal 1
    end

    it 'must return comments added or removed details' do
      results = Analysis::LanguageBreakdown.new(analysis: activity_fact.analysis).collection

      results.length.must_equal 2
      results.first.comments_total.must_equal 3
      results.last.comments_total.must_equal 1
    end

    it 'must return blanks added or removed details over multiple activity_facts' do
      ActivityFact.last.update!(language: activity_fact.language)
      activity_fact.update! blanks_added: 3, blanks_removed: 5
      results = Analysis::LanguageBreakdown.new(analysis: activity_fact.analysis).collection

      results.length.must_equal 1
      results.first.blanks_total.must_equal(-2)
    end
  end
end
