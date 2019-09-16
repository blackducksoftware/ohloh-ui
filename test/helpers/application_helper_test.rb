# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  describe 'expander' do
    it 'should not have any effect if text is nil' do
      text = expander(nil)
      assert_nil text
    end

    it 'should truncate strings on a word boundary' do
      text = expander('It was the best of times.', 5, 10)
      text.gsub(/\s/, '')[0..6].must_equal('It<span')
    end

    it 'should truncate strings without leaving a dangling comma' do
      text = expander('It, or something like it, was the best of times.', 5, 10)
      text.gsub(/\s/, '')[0..6].must_equal('It<span')
    end
  end

  describe 'pluralize_without_count' do
    it 'should pluralize appropriately' do
      pluralize_without_count(3, 'Project').must_equal 'Projects'
      pluralize_without_count(1, 'Project').must_equal 'Project'
      pluralize_without_count(0, 'Project').must_equal 'Projects'
      pluralize_without_count(3, 'Person', 'Accounts').must_equal 'Accounts'
      pluralize_without_count(1, 'Person', 'Accounts').must_equal 'Person'
    end
  end

  describe 'generate_page_name' do
    it 'should return proper page title' do
      stubs(:controller_name).returns('accounts')
      stubs(:action_name).returns('index')

      generate_page_name.must_equal 'accounts_index_page'
    end
  end

  describe 'my_account?' do
    it 'should return true for users own account' do
      user = create(:account)
      stubs(:current_user).returns(user)

      my_account?(user).must_equal true
    end

    it 'should return false for users own account' do
      user = create(:account)
      admin = create(:admin)
      stubs(:current_user).returns(user)

      my_account?(admin).must_equal false
    end
  end

  describe 'xml_date_to_time' do
    it 'should return xml format time for date' do
      xml_date_to_time(Date.current).must_equal "#{Date.current.strftime('%Y-%m-%d')}T00:00:00Z"
    end
  end

  describe 'number_with_delimiter' do
    it 'should return formatted number' do
      number_with_delimiter(50_000, delimiter: '_').must_equal '50_000'
      number_with_delimiter(50_000).must_equal '50,000'
      number_with_delimiter(500).must_equal '500'
      number_with_delimiter(500, delimiter: '_').must_equal '500'
    end
  end

  describe 'time ago in days, hours, and minutes' do
    it 'must return not available when there is no supplied value' do
      time_ago_in_days_hours_minutes(nil).must_equal 'not available'
    end

    it 'must return the correct number of days' do
      time = Time.current.utc - 3.days
      time_ago_in_days_hours_minutes(time).must_match(/3d/)
    end

    it 'must return the correct number of hours' do
      time = Time.current.utc - 4.hours
      time_ago_in_days_hours_minutes(time).must_match(/4h/)
      time_ago_in_days_hours_minutes(time).must_match(/0d 4h/)
    end

    it 'must return the correct number of days and hours' do
      time = Time.current.utc - 3.days - 4.hours
      time_ago_in_days_hours_minutes(time).must_match(/3d 4h/)
    end

    it 'must return the correct number of minutes' do
      time = Time.current.utc - 5.minutes
      time_ago_in_days_hours_minutes(time).must_match(/5m/)
      time_ago_in_days_hours_minutes(time).must_equal('0d 0h 5m')
    end

    it 'must return the fully correct value' do
      time = Time.current.utc - 60.days - 22.hours - 59.minutes
      time_ago_in_days_hours_minutes(time).must_equal '60d 22h 59m'
    end
  end
end
