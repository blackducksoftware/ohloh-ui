require 'test_helper'

class DomainBlacklistsAdminTest < ActionDispatch::IntegrationTest
  it 'index loads' do
    create(:domain_blacklist)
    login_as create(:admin)
    get admin_domain_blacklists_path
    assert_response :success
  end

  it 'show loads' do
    domain_blacklist = create(:domain_blacklist)
    login_as create(:admin)
    get admin_domain_blacklist_path(domain_blacklist)
    assert_response :success
  end

  it 'edit loads' do
    domain_blacklist = create(:domain_blacklist)
    login_as create(:admin)
    get edit_admin_domain_blacklist_path(domain_blacklist)
    assert_response :success
  end
end
