require_relative '../../test_helper'

class Account::OrganizationCoreTest < ActiveSupport::TestCase
  before do
    @org = create(:organization)
    @account = create(:account, organization: @org)
    @project = create(:project, organization: @org)
    @position = create_position(project: @project, account: @account, organization: @org)
    @account_org = Account::OrganizationCore.new(@account.id)
  end

  it 'organizations affiliated with projects I contribute to' do
    orgs_for_my_positions = @account_org.orgs_for_my_positions

    orgs_for_my_positions.size.must_equal 1
    orgs_for_my_positions.first.class.must_equal Organization
    orgs_for_my_positions.first.name.must_equal @project.organization.name
  end

  it 'affiliations for the projects I contributed to' do
    project = @account.positions.first
    project.affiliation = @project.organization
    project.save

    affiliations_for_my_positions = @account_org.affiliations_for_my_positions

    affiliations_for_my_positions.size.must_equal 1
    affiliations_for_my_positions.first.class.must_equal Organization
    affiliations_for_my_positions.first.name.must_equal @project.organization.name
  end

  it 'contributions_to_org_portfolio' do
    @account_org.contributions_to_org_portfolio.must_equal 1
    @account_org.contributions_outside_org.must_equal 0
  end

  it 'contributions_outside_org' do
    analysis = create(:analysis)
    project = create(:project)
    account = create(:account)
    name_fact = create(:name_fact, analysis_id: analysis.id)
    create_position(account: account, project: project, name: name_fact.name)
    project.editor_account = account
    project.update! best_analysis_id: analysis.id, organization_id: create(:organization)
    account.update_column(:organization_id, create(:organization).id)
    account_org = Account::OrganizationCore.new(account.id)
    account.reload

    account_org.contributions_outside_org.must_equal 1
  end
end
