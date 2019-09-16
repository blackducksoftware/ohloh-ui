# frozen_string_literal: true

require 'test_helper'

class Organization::OutsideTest < ActiveSupport::TestCase
  it '#stats' do
    proj1 = create(:project)
    proj2 = create(:project)
    account1 = create(:account, organization_id: proj2.organization_id)
    account2 = create(:account, organization_id: proj1.organization_id)
    po1 = create_position(account: account1, project: proj1, organization: proj1.organization)
    NameFact.where(analysis_id: proj1.best_analysis_id, name_id: po1.name_id).first.update(commits: 2)
    po2 = create_position(account: account2, project: proj1, organization: proj1.organization)
    NameFact.where(analysis_id: proj1.best_analysis_id, name_id: po2.name_id).first.update(commits: 1)
    po3 = create_position(account: account1, project: proj2, organization: proj2.organization)
    NameFact.where(analysis_id: proj2.best_analysis_id, name_id: po3.name_id).first.update(commits: 2)

    stats = proj1.organization.outside_committers_stats
    stats['out_committers'].must_equal '1'
    stats['out_commits'].must_equal '2'
    stats['out_projs'].must_equal '1'
  end

  it '#committers' do
    proj = create(:project)
    account1 = create(:account)
    account2 = create(:account)
    pos = create_position(account: account1, project: proj)
    nf = NameFact.where(analysis_id: proj.best_analysis_id, name_id: pos.name_id).first
    nf.update(twelve_month_commits: 2)
    create_position(account: account2, project: proj)

    accounts = proj.organization.outside_committers(1, 1)
    accounts.length.must_equal 1
    accounts.total_entries.must_equal 2
    accounts.first.id.must_equal account1.id
  end

  it '#projects' do
    proj1 = create(:project)
    proj2 = create(:project)
    proj3 = create(:project)
    account = create(:account, organization_id: proj1.organization_id)
    create_position(account: account, project: proj1, organization: proj1.organization)
    create_position(account: account, project: proj2, organization: proj2.organization)
    create_position(account: account, project: proj3, organization: proj3.organization)

    projects = proj1.organization.outside_projects(1, 1)
    projects.length.must_equal 1
    projects.total_entries.must_equal 2
    projects.first.id.must_equal proj2.id
  end
end
