require_relative '../../test_helper'

class Account::OrganizationCoreTest < ActiveSupport::TestCase
  def setup
    @account = accounts(:admin)
    @account_org = Account::OrganizationCore.new(@account.id)
  end

  test 'organizations affiliated with projects I contribute to' do
    orgs_for_my_positions = @account_org.orgs_for_my_positions

    assert_equal 1, orgs_for_my_positions.size
    assert_equal Organization, orgs_for_my_positions.first.class
    assert_equal 'Linux Foundations', orgs_for_my_positions.first.name
  end

  test 'affiliations for the projects I contributed to' do
    project = @account.positions.first
    project.affiliation = Organization.where { id.eq(1) }.first
    project.save

    affiliations_for_my_positions = @account_org.affiliations_for_my_positions

    assert_equal 1, affiliations_for_my_positions.size
    assert_equal Organization, affiliations_for_my_positions.first.class
    assert_equal 'Linux Foundations', affiliations_for_my_positions.first.name
  end

  test 'contributions_to_org_portfolio' do
    analysis = analyses(:linux)
    projects(:linux).update_attributes! best_analysis_id: analysis.id
    @account.update_column :organization_id, organizations(:linux).id
    @account.reload

    assert_equal 1, @account_org.contributions_to_org_portfolio
    assert_equal 0, @account_org.contributions_outside_org
  end

  test 'contributions_outside_org' do
    analysis = analyses(:linux)
    projects(:linux).update_attributes! best_analysis_id: analysis.id
    account = accounts(:user)
    account.update_column(:organization_id, organizations(:google).id)
    account_org = Account::OrganizationCore.new(account.id)
    account.reload

    assert_equal 1, account_org.contributions_outside_org
  end
end
