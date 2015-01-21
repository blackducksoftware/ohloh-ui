require 'test_helper'

class CommitsByLanguageTest < Draper::TestCase
  before do
    Draper::ViewContext.clear!
  end

  let(:cbl) do
    [{ 'l_id' => '3', 'l_name' => 'xml', 'l_category' => '1', 'l_nice_name' => 'XML',
       'month' => '2009-06-01', 'commits' => '8' },
     { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
       'month' => '2009-06-01', 'commits' => '24' },
     { 'l_id' => '1', 'l_name' => 'html', 'l_category' => '1', 'l_nice_name' => 'HTML',
       'month' => '2009-07-01', 'commits' => '9' },
     { 'l_id' => '3', 'l_name' => 'xml', 'l_category' => '1', 'l_nice_name' => 'XML',
       'month' => '2009-07-01', 'commits' => '29' },
     { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
       'month' => '2009-07-01', 'commits' => '37' },
     { 'l_id' => '3', 'l_name' => 'xml', 'l_category' => '1', 'l_nice_name' => 'XML',
       'month' => '2009-08-01', 'commits' => '7' },
     { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
       'month' => '2009-08-01', 'commits' => '27' },
     { 'l_id' => '30', 'l_name' => 'sql', 'l_category' => '0', 'l_nice_name' => 'SQL',
       'month' => '2009-08-01', 'commits' => '1' },
     { 'l_id' => '3', 'l_name' => 'xml', 'l_category' => '1', 'l_nice_name' => 'XML',
       'month' => '2009-09-01', 'commits' => '2' },
     { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
       'month' => '2009-09-01', 'commits' => '16' },
     { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
       'month' => '2009-10-01', 'commits' => '1' },
     { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
       'month' => '2009-11-01', 'commits' => '8' },
     { 'l_id' => '3', 'l_name' => 'xml', 'l_category' => '1', 'l_nice_name' => 'XML',
       'month' => '2009-12-01', 'commits' => '12' },
     { 'l_id' => '12', 'l_name' => 'ruby', 'l_category' => '0', 'l_nice_name' => 'Ruby',
       'month' => '2009-12-01', 'commits' => '2' },
     { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
       'month' => '2009-12-01', 'commits' => '26' },
     { 'l_id' => '3', 'l_name' => 'xml', 'l_category' => '1', 'l_nice_name' => 'XML',
       'month' => '2010-01-01', 'commits' => '2' },
     { 'l_id' => '12', 'l_name' => 'ruby', 'l_category' => '0', 'l_nice_name' => 'Ruby',
       'month' => '2010-01-01', 'commits' => '3' },
     { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
       'month' => '2010-01-01', 'commits' => '9' }]
  end

  let(:user) do
    accounts(:user).best_vita.vita_fact.update(commits_by_language: cbl)
    accounts(:user)
  end

  let(:admin) { accounts(:admin) }

  let(:cbl_decorator) do
    user.stubs(:first_commit_date).returns(Time.strptime('2009-06-01', '%Y-%m-01').to_date)
    CommitsByLanguage.new(user, context: { scope: 'full' })
  end

  describe 'language_experience' do
    it 'should return languages with most commits sorted first for seven year range' do
      le = cbl_decorator.language_experience
      le[:object_array].size.must_equal 5
      le[:object_array].first.name.must_equal 'csharp'
    end

    it 'should all required data for each language' do
      le = cbl_decorator.language_experience
      language = le[:object_array].first

      language.language_id.must_equal '17'
      language.name.must_equal 'csharp'
      language.nice_name.must_equal 'C#'
      language.color_code.must_equal '4096EE'
      language.commits.must_equal [0] * 17 + [24, 37, 27, 16, 1, 8, 26, 9] + [0] * 59
      language.category.must_equal '0'
    end

    it 'should get seven years of commits for each language' do
      le = cbl_decorator.language_experience
      le[:object_array].size.must_equal 5
      le[:object_array].first.commits.size.must_equal 7 * 12
    end

    it 'should get seven years of months for date values' do
      le = cbl_decorator.language_experience
      le[:date_array].size.must_equal 7 * 12
    end

    it 'should return empty array for user with no positions' do
      cbl_decorator = CommitsByLanguage.new admin, context: { scope: 'full' }
      le = cbl_decorator.language_experience
      le[:object_array].must_equal []
      le[:date_array].size.must_equal 7 * 12
    end

    it 'should try to fetch data from first_commit_date if it is more than seven years' do
      admin.stubs(:first_commit_date).returns(Time.strptime('2004-01-01', '%Y-%m-01').to_date)
      cbl_decorator = CommitsByLanguage.new admin, context: { scope: 'full' }
      le = cbl_decorator.language_experience
      le[:object_array].must_equal []
      le[:date_array].size.must_equal 11 * 12
    end
  end
end
