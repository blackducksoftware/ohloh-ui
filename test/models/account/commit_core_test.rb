require_relative '../../test_helper'

class Account::CommitCoreTest < ActiveSupport::TestCase
  fixtures :accounts, :projects, :name_facts, :analyses, :commits

  def setup
    @account_1 = accounts(:admin)
    account_2 = accounts(:user)

    analysis = analyses(:linux)
    project = projects(:linux)
    project.update_attributes! best_analysis_id: analysis.id

    @account_commits = Account::CommitCore.new([@account_1.id, account_2.id])
  end

  test 'most_and_recent_data should return values when present' do
    commits_data = @account_commits.most_and_recent_data

    assert_equal 1, commits_data[@account_1.id].size
    assert_equal 1, commits_data[@account_1.id].first.account_id
    assert_equal 1, commits_data[@account_1.id].first.project_id
    assert_equal 'Linux', commits_data[@account_1.id].first.name
    assert_equal 'linux', commits_data[@account_1.id].first.url_name
  end

  test 'most_and_recent_data should return {} when account_ids is []' do
    account_commits = Account::CommitCore.new([])
    assert_equal true, account_commits.most_and_recent_data.empty?
  end

  test 'most_and_recent_data should return {} when account_ids given have no data' do
    account_commits = Account::CommitCore.new([0])
    assert_equal true, account_commits.most_and_recent_data.empty?
  end
end
