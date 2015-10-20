require 'test_helper'

class AllMonthTest < ActiveSupport::TestCase
  describe 'all_attributes' do
    it 'must return all attributes as an array of hashes' do
      date_range = [3.months.ago, 2.months.ago, 1.month.ago, Date.today].map(&:beginning_of_month)
      date_range.each { |date| create(:all_month, month: date) }

      start_date = 2.months.ago.beginning_of_month.to_s(:db)
      end_date = Time.now.beginning_of_month.to_s(:db)
      data = AllMonth.all_attributes(start_date, end_date)

      data.size.must_equal 3
      data.first['this_month'].must_equal start_date
      data.last['this_month'].must_equal end_date
      data.map { |hsh| hsh['count'] }.uniq.must_equal ['0']
    end
  end
end
