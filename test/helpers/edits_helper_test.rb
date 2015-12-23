require 'test_helper'

class EditsHelperTest < ActionView::TestCase
  include EditsHelper

  describe 'edit_humanize_datetime' do
    it 'reduce to time_ago_in_words when it was today' do
      edit_humanize_datetime(Time.current - 1.second).must_match 'ago'
      edit_humanize_datetime(Time.current - 1.minute).must_match 'ago'
      edit_humanize_datetime(Time.current - 1.hour).must_match 'ago'
    end

    it 'drop the year if it was this year' do
      other_time = Time.current - 17.days
      dont_fail_around_new_years_date = Time.new(Time.current.year, other_time.month, other_time.day).in_time_zone
      edit_humanize_datetime(dont_fail_around_new_years_date).wont_match Time.current.year
    end

    it 'includes the year if it was before this year' do
      other_time = Time.current - 1700.days
      edit_humanize_datetime(other_time).must_match other_time.year.to_s
    end
  end

  describe 'edit_explanation_enlistment' do
    it 'must return property edit explanation' do
      edit_explanation_enlistment(create(:property_edit)).must_equal I18n.t('edits.explanation_enlistment_ignored')
    end

    it 'must return enlistment explanation' do
      enlistment = create(:enlistment)
      edit = create(:create_edit, target: enlistment)
      edit_explanation_enlistment(edit).must_equal I18n.t('edits.explanation_enlistment',
                                                          url: enlistment.repository.url,
                                                          name: enlistment.repository.module_name)
    end
  end
end
