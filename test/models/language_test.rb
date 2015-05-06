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

  describe 'total' do
    it 'determines the total sum of code, comments, and blanks' do
      language = create(:language, code: 10_000_000, comments: 10_000_000, blanks: 10_000_000)
      total = language.code + language.comments + language.blanks
      total.must_equal language.total
    end
  end
end
