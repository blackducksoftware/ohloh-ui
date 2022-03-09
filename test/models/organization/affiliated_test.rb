# frozen_string_literal: true

require 'test_helper'

class Organization::AffiliatedTest < ActiveSupport::TestCase
  it '#stats' do
    proj1 = create(:project)
    proj2 = create(:project)
    account1 = create(:account, organization_id: proj1.organization_id)
    account2 = create(:account, organization_id: proj1.organization_id)
    po1 = create_position(account: account1, project: proj1, organization: proj1.organization)
    NameFact.where(analysis_id: proj1.best_analysis_id, name_id: po1.name_id).first.update(commits: 2)
    po2 = create_position(account: account2, project: proj1, organization: proj1.organization)
    NameFact.where(analysis_id: proj1.best_analysis_id, name_id: po2.name_id).first.update(commits: 1)
    po3 = create_position(account: account1, project: proj2, organization: proj2.organization)
    NameFact.where(analysis_id: proj2.best_analysis_id, name_id: po3.name_id).first.update(commits: 2)

    acs = proj1.organization.affiliated_committers_stats
    _(acs['affl_committers']).must_equal 2
    _(acs['affl_commits']).must_equal 3
    _(acs['affl_projects']).must_equal 1
    _(acs['affl_committers_out']).must_equal 1
    _(acs['affl_commits_out']).must_equal 2
    _(acs['affl_projects_out']).must_equal 1
  end

  it '#committers' do
    proj = create(:project)
    account1 = create(:account, organization_id: proj.organization_id)
    account1.person.update(kudo_position: 100)
    account2 = create(:account, organization_id: proj.organization_id)
    create_position(account: account1, project: proj, organization: proj.organization)
    create_position(account: account2, project: proj, organization: proj.organization)

    accounts = proj.organization.affiliated_committers(1, 1)
    _(accounts.length).must_equal 1
    _(accounts.total_entries).must_equal 2
    _(accounts.first.id).must_equal account1.id
  end

  it '#projects' do
    org = create(:organization)
    proj1 = create(:project, organization: org, user_count: 2)
    proj2 = create(:project, organization: org, user_count: 1)
    projects = org.affiliated_projects(1, 2)
    _(projects.length).must_equal 2
    _(projects.total_entries).must_equal 2
    _(projects.first.id).must_equal proj1.id
    _(projects.last.id).must_equal proj2.id
  end
end
