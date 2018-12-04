require 'test_helper'

class LanguageTest < ActiveSupport::TestCase
  describe 'new_languages_for_project' do
    it 'must sort languages by time and data' do
      commit_flag1 = CommitFlag.new(time: 1.day.ago, data: :first)
      commit_flag2 = CommitFlag.new(time: 2.days.ago, data: :first)
      commit_flag3 = CommitFlag.new(time: 3.days.ago, data: :second)
      languages = stub(where: [commit_flag1, commit_flag2, commit_flag3])
      commit_flags = stub(new_languages: languages)
      project = stub(commit_flags: commit_flags)

      Language.new_languages_for_project(project, 2).must_equal(
        second: [commit_flag3], first: [commit_flag2, commit_flag1]
      )
    end
  end

  describe 'map' do
    it 'should return a name map of all languages' do
      create(:language, name: 'name_1', nice_name: 'nice_name_1')
      create(:language, name: 'name_2', nice_name: 'nice_name_2')

      Language.map.must_include ['All Languages', '']
      Language.map.must_include %w[nice_name_1 name_1]
      Language.map.must_include %w[nice_name_2 name_2]
    end
  end

  describe 'total' do
    it 'determines the total sum of code, comments, and blanks' do
      language = create(:language, code: 10_000_000, comments: 10_000_000, blanks: 10_000_000)
      total = language.code + language.comments + language.blanks
      total.must_equal language.total
    end
  end

  describe 'to_param' do
    it 'should return the name' do
      language = create(:language)
      language.to_param.must_equal language.name
    end
  end

  describe 'preload_active_and_experienced_accounts' do
    it 'should return most experienced and active accounts' do
      account1 = create(:account)
      account2 = create(:account)
      account3 = create(:account)
      language = create(:language, active_contributors: [[account1.id, 1234], [account2.id, 123]],
                                   experienced_contributors: [[account3.id, 343]])
      language_preloads = language.preload_active_and_experienced_accounts
      language_preloads.keys.sort.must_equal [account1.id, account2.id, account3.id].sort
      language_preloads[account1.id].must_equal [account1]
      language_preloads[account2.id].must_equal [account2]
      language_preloads[account3.id].must_equal [account3]
    end
  end
end
