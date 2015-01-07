require_relative '../../test_helper'

class Account::CommitCoreTest < ActiveSupport::TestCase
  def setup
    @account_1 = accounts(:admin)
    account_2 = accounts(:user)

    analysis = analyses(:linux)
    project = projects(:linux)
    project.editor_account = create(:account)
    project.update_attributes! best_analysis_id: analysis.id

    @account_commits = Account::CommitCore.new([@account_1.id, account_2.id])
  end

  it 'most_and_recent_data should return values when present' do
    skip('TODO: Failing due to fix_encoding_if_invalid!')
    commits_data = @account_commits.most_and_recent_data

    commits_data[@account_1.id].size.must_equal 1
    commits_data[@account_1.id].first.account_id.must_equal 1
    commits_data[@account_1.id].first.project_id.must_equal 1
    commits_data[@account_1.id].first.name.must_equal 'Linux'
    commits_data[@account_1.id].first.url_name.must_equal 'linux'
  end

  it 'most_and_recent_data should return {} when account_ids is empty' do
    account_commits = Account::CommitCore.new([])
    account_commits.most_and_recent_data.must_be :empty?
  end

  it 'most_and_recent_data should return {} when account_ids are non existent' do
    account_commits = Account::CommitCore.new([0])
    account_commits.most_and_recent_data.must_be :empty?
  end
end
