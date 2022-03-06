# frozen_string_literal: true

require 'test_helper'

class Analysis::MonthlyLanguageTest < ActiveSupport::TestCase
  it 'should return no data when montly_language_analysis is empty' do
    _(Analysis::MonthlyLanguage.last_run).must_equal I18n.t('.no_data')
  end

  it 'should return no data when montly_language_analysis is empty' do
    set_last_run_date = '2016-04-01'
    Setting.create(key: 'monthly_language_analysis', value: set_last_run_date)
    _(Analysis::MonthlyLanguage.last_run).must_equal set_last_run_date.to_date.to_s(:mdy)
  end
end
