require 'test_helper'

class DomainBlacklistsAdminTest < ActionDispatch::IntegrationTest
  it 'index loads' do
    create(:domain_blacklist)
    admin = create(:admin, password: 'xyzzy123456')
    admin.password = 'xyzzy123456'
    login_as admin
    get admin_domain_blacklists_path
    assert_response :success
  end

  it 'show loads' do
    domain_blacklist = create(:domain_blacklist)
    admin = create(:admin, password: 'xyzzy123456')
    admin.password = 'xyzzy123456'
    login_as admin
    get admin_domain_blacklist_path(domain_blacklist)
    assert_response :success
  end

  it 'edit loads' do
    domain_blacklist = create(:domain_blacklist)
    admin = create(:admin, password: 'xyzzy123456')
    admin.password = 'xyzzy123456'
    login_as admin
    get edit_admin_domain_blacklist_path(domain_blacklist)
    assert_response :success
  end
end
