# frozen_string_literal: true

require 'test_helper'

class Account::CommitCoreTest < ActiveSupport::TestCase
  let(:account_1) { create(:admin) }
  let(:account_2) { create(:account) }
  let(:project) { create(:project) }
  let(:analysis) { project.best_analysis }
  let(:account_commits) { Account::CommitCore.new([account_1.id, account_2.id]) }

  it 'most_and_recent_data should return values when present' do
    create_position(project: project, account: account_1)

    commits_data = account_commits.most_and_recent_data

    commits_data.must_be :present?
    commits_data[account_1.id].size.must_equal 1
    commits_data[account_1.id].first.account_id.must_equal account_1.id
    commits_data[account_1.id].first.project_id.must_equal project.id
    commits_data[account_1.id].first.name.must_equal project.name
    commits_data[account_1.id].first.vanity_url.must_equal project.vanity_url
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
