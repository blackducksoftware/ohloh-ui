# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/commits_by_language_data'

class CommitsByLanguageTest < ActiveSupport::TestCase
  let(:start_date) { (Date.current - 6.years).beginning_of_month }
  let(:account) { create_account_with_commits_by_language }
  let(:admin) { create(:admin) }
  let(:cbl_decorator) do
    account.stubs(:first_commit_date).returns(start_date)
    CommitsByLanguage.new(account, context: { scope: 'full' })
  end

  describe 'language_experience' do
    it 'should return languages with most commits sorted first for seven year range' do
      le = cbl_decorator.language_experience
      _(le[:object_array].size).must_equal 5
      _(le[:object_array].first.name).must_equal 'csharp'
    end

    it 'should all required data for each language' do
      le = cbl_decorator.language_experience
      language = le[:object_array].first

      _(language.language_id).must_equal '17'
      _(language.name).must_equal 'csharp'
      _(language.nice_name).must_equal 'C#'
      _(language.color_code).must_equal '4096EE'
      _(language.commits).must_equal ([0] * 12) + [24, 37, 27, 16, 1, 8, 26, 9] + ([0] * 64)
      _(language.category).must_equal '0'
    end

    it 'should get seven years of commits for each language' do
      le = cbl_decorator.language_experience
      _(le[:object_array].size).must_equal 5
      _(le[:object_array].first.commits.size).must_equal 7 * 12
    end

    it 'should get seven years of months for date values' do
      le = cbl_decorator.language_experience
      _(le[:date_array].size).must_equal 7 * 12
    end

    it 'should return empty array for account with no positions' do
      cbl_decorator = CommitsByLanguage.new admin, context: { scope: 'full' }
      le = cbl_decorator.language_experience
      _(le[:object_array]).must_equal []
      _(le[:date_array].size).must_equal 7 * 12
    end

    it 'should try to fetch data from first_commit_date if it is more than seven years' do
      admin.stubs(:first_commit_date).returns(start_date - 5.years)
      cbl_decorator = CommitsByLanguage.new admin, context: { scope: 'full' }
      le = cbl_decorator.language_experience
      _(le[:object_array]).must_equal []
      _(le[:date_array].size).must_equal 11 * 12
    end
  end
end
