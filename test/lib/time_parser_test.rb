# frozen_string_literal: true

require 'test_helper'

describe 'TimeParser' do
  describe 'months_in_range' do
    it 'should return months in between given range of dates' do
      dates = TimeParser.months_in_range(Date.current - 2.months, Date.current)
      _(dates.size).must_equal 3
      _(dates.first).must_equal((Date.current - 2.months).beginning_of_month)
      _(dates[1]).must_equal((Date.current - 1.month).beginning_of_month)
      _(dates.last).must_equal(Date.current.beginning_of_month)
    end
  end
end
