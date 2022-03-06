# frozen_string_literal: true

require 'test_helper'

class Analysis::LanguagesBreakdownTest < ActiveSupport::TestCase
  let(:activity_fact) do
    create(:activity_fact, code_added: 5, code_removed: 3, comments_added: 3, comments_removed: 0)
  end

  before do
    create(:activity_fact, analysis: activity_fact.analysis, code_added: 6, code_removed: 5,
                           comments_added: 5, comments_removed: 4)
  end

  describe 'collection' do
    it 'must group results by language' do
      ActivityFact.last.update!(language: activity_fact.language)
      results = Analysis::LanguagesBreakdown.new(analysis: activity_fact.analysis).collection

      _(results.length).must_equal 1
      _(results.first.code_total).must_equal 3
      _(results.first.comments_total).must_equal 4
    end

    it 'must not return activity_facts with zero code or comment totals' do
      activity_fact.update! code_added: 5, code_removed: 5,
                            comments_added: 5, comments_removed: 5
      ActivityFact.last.update! code_added: 5, code_removed: 5,
                                comments_added: 5, comments_removed: 5

      results = Analysis::LanguagesBreakdown.new(analysis: activity_fact.analysis).collection
      _(results).must_be :empty?
    end

    it 'must return code added or removed details' do
      results = Analysis::LanguagesBreakdown.new(analysis: activity_fact.analysis).collection

      _(results.length).must_equal 2
      _(results.first.code_total).must_equal 2
      _(results.last.code_total).must_equal 1
    end

    it 'must return comments added or removed details' do
      results = Analysis::LanguagesBreakdown.new(analysis: activity_fact.analysis).collection

      _(results.length).must_equal 2
      _(results.first.comments_total).must_equal 3
      _(results.last.comments_total).must_equal 1
    end

    it 'must return blanks added or removed details over multiple activity_facts' do
      ActivityFact.last.update!(language: activity_fact.language)
      activity_fact.update! blanks_added: 3, blanks_removed: 5
      results = Analysis::LanguagesBreakdown.new(analysis: activity_fact.analysis).collection

      _(results.length).must_equal 1
      _(results.first.blanks_total).must_equal(-2)
    end
  end

  describe 'map' do
    it 'must return blanks added or removed details over multiple activity_facts' do
      language = activity_fact.language
      ActivityFact.last.update!(language: language)
      activity_fact.update! blanks_added: 3, blanks_removed: 5, code_removed: 5, code_added: 10,
                            comments_added: 10, comments_removed: 5
      results = Analysis::LanguagesBreakdown.new(analysis: activity_fact.analysis).map

      _(results.length).must_equal 1
      _(results.first[:id]).must_equal language.id
      _(results.first[:nice_name]).must_equal language.nice_name
      _(results.first[:name]).must_equal language.name
      _(results.first[:lines]).must_equal 10
    end
  end
end
