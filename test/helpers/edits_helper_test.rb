# frozen_string_literal: true

require 'test_helper'

class EditsHelperTest < ActionView::TestCase
  include ERB::Util
  include EditsHelper

  describe 'edit_humanize_datetime' do
    it 'reduce to time_ago_in_words when it was today' do
      _(edit_humanize_datetime(Time.current - 1.second)).must_match 'ago'
      _(edit_humanize_datetime(Time.current - 1.minute)).must_match 'ago'
      _(edit_humanize_datetime(Time.current - 1.hour)).must_match 'ago'
    end

    it 'drop the year if it was this year' do
      other_time = Time.current - 17.days
      dont_fail_around_new_years_date = Time.new(Time.current.year, other_time.month, other_time.day).in_time_zone
      _(edit_humanize_datetime(dont_fail_around_new_years_date)).wont_match Time.current.year
    end

    it 'includes the year if it was before this year' do
      other_time = Time.current - 1700.days
      _(edit_humanize_datetime(other_time)).must_match other_time.year.to_s
    end
  end

  describe 'edit_explanation_enlistment' do
    it 'must return property edit explanation' do
      _(edit_explanation_enlistment(create(:property_edit))).must_equal I18n.t('edits.explanation_enlistment_ignored')
    end

    it 'must return enlistment explanation' do
      enlistment = create(:enlistment)
      enlistment.stubs(:code_location).returns(code_location_stub)
      edit = create(:create_edit, target: enlistment)
      _(edit_explanation_enlistment(edit)).must_equal I18n.t('edits.explanation_enlistment',
                                                             url: enlistment.code_location.url)
    end
  end

  describe 'edit_show_subject' do
    describe 'Enlistment' do
      it 'should display branch name if there is branch_name' do
        ApiAccess.stubs(:available?).returns(true)
        WebMocker.get_code_location
        enlistment = create_enlistment_with_code_location
        @parent = enlistment.project
        edit = create(:create_edit, target: enlistment)
        _(edit_show_subject(edit)).must_match "Branch: #{enlistment.code_location.branch}"
      end

      it 'should not display neither branch nor module name if both are empty' do
        ApiAccess.stubs(:available?).returns(true)
        enlistment = create(:enlistment)
        enlistment.code_location = CodeLocation.new
        @parent = enlistment.project
        edit = create(:create_edit, target: enlistment)
        _(edit_show_subject(edit)).wont_match 'Branch: '
      end
    end
  end

  describe 'edit_get_value_enlistment' do
    it 'should return nice_url of code_location for create edit' do
      enlistment = create(:enlistment)
      enlistment.stubs(:code_location).returns(code_location_stub)
      edit = create(:create_edit, target: enlistment)
      _(edit_get_value_enlistment(edit)).must_match enlistment.code_location.nice_url
    end

    it 'should return nil for property edit' do
      enlistment = create(:enlistment)
      edit = create(:property_edit, target: enlistment)
      _(edit_get_value_enlistment(edit)).must_be_nil
    end
  end
end
