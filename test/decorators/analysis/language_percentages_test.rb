# frozen_string_literal: true

require 'test_helper'

class Analysis::LanguagePercentagesTest < ActiveSupport::TestCase
  let(:analysis) { create(:analysis) }

  let(:language_breakdown) do
    [{ id: 1, nice_name: 'XML', name: 'xml', lines: 200 }, { id: 2, nice_name: 'SQL', name: 'sql', lines: 150 },
     { id: 3, nice_name: 'HTML', name: 'html', lines: 130 }, { id: 4, nice_name: 'CSS', name: 'css', lines: 120 },
     { id: 5, nice_name: 'C++', name: 'c++', lines: 40 }, { id: 6, nice_name: 'C', name: 'c', lines: 20 }]
  end

  describe 'collection' do
    it 'return chart data' do
      Analysis::LanguagesBreakdown.any_instance.stubs(:map).returns(language_breakdown)
      results = Analysis::LanguagePercentages.new(analysis).collection

      _(results.first.first).must_equal 1
      _(results.first.second).must_equal 'XML'
      _(results.first.third[:vanity_url]).must_equal 'xml'
      _(results.first.third[:percent]).must_equal 30
      _(results.first.third[:color]).must_equal '555555'

      _(results.second.first).must_equal 2
      _(results.second.second).must_equal 'SQL'
      _(results.second.third[:vanity_url]).must_equal 'sql'
      _(results.second.third[:percent]).must_equal 23
      _(results.second.third[:color]).must_equal '493625'

      _(results.third.first).must_equal 3
      _(results.third.second).must_equal 'HTML'
      _(results.third.third[:vanity_url]).must_equal 'html'
      _(results.third.third[:percent]).must_equal 20
      _(results.third.third[:color]).must_equal '47A400'

      _(results.fourth.first).must_be_nil
      _(results.fourth.second).must_equal '3 Other'
      _(results.fourth.third[:percent]).must_equal 27
      _(results.fourth.third[:color]).must_equal '000000'
      _(results.fourth.third[:composed_of].first).must_equal [4, 'CSS', { percent: 18 }]
      _(results.fourth.third[:composed_of].second).must_equal [5, 'C++', { percent: 6 }]
      _(results.fourth.third[:composed_of].last).must_equal [6, 'C', { percent: 3 }]
    end
  end
end
