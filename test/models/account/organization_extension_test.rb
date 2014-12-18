require_relative '../../test_helper'

class OrganizationExtensionTest < ActiveSupport::TestCase
  fixtures :accounts, :organizations, :projects, :name_facts, :analyses

  test "organizations affiliated with projects I contribute to" do
    Account.first
    a = accounts(:admin)
    
    orgs_for_my_positions = a.organization_extension.orgs_for_my_positions
    
    assert_equal 1, orgs_for_my_positions.size
    assert_equal Organization, orgs_for_my_positions.first.class
    assert_equal "Linux Foundations", orgs_for_my_positions.first.name
  end

  test "affiliations for the projects I contributed to" do
    a = accounts(:admin)
    p = a.positions.first
    p.affiliation = Organization.where{id.eq(1)}.first
    p.save

    affiliations_for_my_positions = a.organization_extension.affiliations_for_my_positions
    
    assert_equal 1, affiliations_for_my_positions.size
    assert_equal Organization, affiliations_for_my_positions.first.class
    assert_equal 'Linux Foundations', affiliations_for_my_positions.first.name
  end

  test 'contributions_to_org_portfolio' do
    analysis = analyses(:linux)
    projects(:linux).update_attributes! best_analysis_id: analysis.id
    accounts(:admin).update_attributes! organization_id: organizations(:linux).id

    assert_equal 1, accounts(:admin).organization_extension.contributions_to_org_portfolio
    assert_equal 0, accounts(:admin).organization_extension.contributions_outside_org
  end

  test 'contributions_outside_org' do
    analysis = analyses(:linux)
    projects(:linux).update_attributes! best_analysis_id: analysis.id
    accounts(:user).update_attributes! organization_id: organizations(:google).id

    assert_equal 1, accounts(:user).organization_extension.contributions_outside_org
  end
end
