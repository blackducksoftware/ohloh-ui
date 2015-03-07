require 'test_helper'

class EditsHelperTest < ActionView::TestCase
  include EditsHelper

  describe 'edit_humanize_datetime' do
    it 'reduce to time_ago_in_words when it was today' do
      edit_humanize_datetime(Time.now - 1.second).must_match 'ago'
      edit_humanize_datetime(Time.now - 1.minute).must_match 'ago'
      edit_humanize_datetime(Time.now - 1.hour).must_match 'ago'
    end

    it 'drop the year if it was this year' do
      other_time = Time.now - 17.days
      dont_fail_around_new_years_date = Time.new(Time.now.year, other_time.month, other_time.day)
      edit_humanize_datetime(dont_fail_around_new_years_date).wont_match Time.now.year
    end

    it 'includes the year if it was before this year' do
      other_time = Time.now - 1700.days
      edit_humanize_datetime(other_time).must_match other_time.year.to_s
    end
  end
end
