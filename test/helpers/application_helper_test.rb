require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  describe 'expander' do
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
end
