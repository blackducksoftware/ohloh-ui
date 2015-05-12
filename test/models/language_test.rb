require 'test_helper'

class LanguageTest < ActiveSupport::TestCase
  describe 'new_languages_for_project' do
    it 'must sort languages by time and data' do
      commit_flag_1 = CommitFlag.new(time: 1.day.ago, data: :first)
      commit_flag_2 = CommitFlag.new(time: 2.days.ago, data: :first)
      commit_flag_3 = CommitFlag.new(time: 3.days.ago, data: :second)
      languages = stub(where: [commit_flag_1, commit_flag_2, commit_flag_3])
      commit_flags = stub(new_languages: languages)
      project = stub(commit_flags: commit_flags)

      Language.new_languages_for_project(project, 2).must_equal(
        second: [commit_flag_3], first: [commit_flag_2, commit_flag_1]
      )
    end
  end

  describe 'map' do
    it 'should return a name map of all languages' do
      create(:language, name: 'name_1', nice_name: 'nice_name_1')
      create(:language, name: 'name_2', nice_name: 'nice_name_2')

      Language.map.must_include ['All Languages', '']
      Language.map.must_include %w(nice_name_1 name_1)
      Language.map.must_include %w(nice_name_2 name_2)
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
      account_1 = create(:account)
      account_2 = create(:account)
      account_3 = create(:account)
      language = create(:language, active_contributors: [[account_1.id, 1234], [account_2.id, 123]],
                                   experienced_contributors: [[account_3.id, 343]])
      language_preloads = language.preload_active_and_experienced_accounts
      language_preloads.keys.must_equal [account_1.id, account_2.id, account_3.id]
      language_preloads[account_1.id].must_equal [account_1]
      language_preloads[account_2.id].must_equal [account_2]
      language_preloads[account_3.id].must_equal [account_3]
    end
  end
end
