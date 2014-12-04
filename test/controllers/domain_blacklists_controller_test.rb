require_relative '../test_helper'

class DomainBlacklistsControllerTest < ActionController::TestCase
  def setup
    login_as :jason
    @controller = DomainBlacklistsController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  test 'index requires login' do
    skip('TODO: accounts')
    get :index
    assert_response :redirect
  end

  test 'index requires admin' do
    skip('TODO: accounts')
    login_as :robin
    get :index
    assert_response :redirect
  end

  test 'index without domains has notice' do
    skip('TODO: layout_params')
    login_as :jason
    get :index
    assert_select 'div.alert', text: EncodedRegexp.new('No Domains Blacklisted')
  end

  test 'index' do
    get :index
    assert_equal 'No Domains Blacklisted', flash[:notice]
    assert_response :success
    assert_select 'h3', text: 'Blacklist Domains'
    assert_select 'a[href=/domain_blacklists/new]', text: 'Add New Domain'
  end

  test 'link to add new domain' do
    get :index
    assert_equal 'No Domains Blacklisted', flash[:notice]
    assert_response :success
    assert_select 'h3', text: 'Blacklist Domains'
    assert_select 'a[href=/domain_blacklists/new]', text: 'Add New Domain'
  end

  test 'new domain page form has new domain field' do
    get :new
    assert_response :success
    assert_select 'h1', text: 'Add New Domain Blacklist'
    assert_select 'form[action=/domain_blacklists]'
    assert_select 'label[for=domain_blacklist_domain]', text: 'New Domain to Blacklist:'
    assert_select 'input[id=domain_blacklist_domain]', type: 'text'
    assert_select 'input[name=commit]', type: 'submit'
  end

  test 'posting the form with a new domain should create a new record' do
    assert_equal 0, DomainBlacklist.count
    post :create, domain_blacklist: { domain: 'mindpowerup.com' }
    assert_not_nil assigns :domain_blacklist
    assert_equal 0,  (assigns :domain_blacklist).errors.count
    assert_equal 'Domain successfully added to blacklist', flash[:success]
    assert_equal 1, DomainBlacklist.count
    assert_redirected_to domain_blacklists_path
  end

  test 'posting the form with an existing domain fails' do
    bad_domain = 'cruddysite.com'
    DomainBlacklist.create(domain: bad_domain)
    assert_equal 1, DomainBlacklist.count
    post :create, domain_blacklist: { domain: bad_domain }
    assert_not_nil assigns :domain_blacklist
    assert_equal 1, (assigns :domain_blacklist).errors.count
    assert_equal 'Unable to add domain to blacklist', flash[:error]
    assert_equal 1, DomainBlacklist.count
    assert_redirected_to new_domain_blacklist_path
  end

  test 'index show list of blacklisted domains' do
    create_two_blacklisted_domains
    get :index
    assert_select 'td', text: 'bad_domain.com'
    assert_select 'td', text: 'spam_domain.com'
  end

  test 'index table has edit and delete links' do
    create_two_blacklisted_domains
    bad = DomainBlacklist.find_by_domain('bad_domain.com')
    get :index
    assert_select 'tr' do
      assert_select 'td', text: 'bad_domain.com'
      assert_select 'td' do
        assert_select "a[href=#{edit_domain_blacklist_path(bad)}]", text: 'Edit'
        assert_select "a[href=#{domain_blacklist_path(bad)}]", text: 'Delete'
      end
    end
  end

  test 'edit domain page allows edit' do
    create_two_blacklisted_domains
    domain = DomainBlacklist.find_by_domain('bad_domain.com')
    get :edit, id: domain.id
    assert_response :success
    assert_select "form[action=#{domain_blacklist_path(domain)}][method=post]" do
      assert_select 'label', text: 'Blacklisted Domain'
      assert_select "input[value=#{domain.domain}]"
      assert_select 'input[type=submit][value=Update Domain]'
    end
  end

  test 'update updates a blacklisted domain' do
    create_two_blacklisted_domains
    domain = DomainBlacklist.find_by_domain('bad_domain.com')
    put :update, id: domain.id, domain_blacklist: { 'domain' => 'really_bad_domain.com' }
    assert_redirected_to domain_blacklists_path
    domain.reload
    assert domain.domain == 'really_bad_domain.com'
  end

  test 'update when the new name is a conflict shows an error message' do
    create_two_blacklisted_domains
    domain = DomainBlacklist.find_by_domain('bad_domain.com')
    put :update, id: domain.id, domain_blacklist: { 'domain' => 'spam_domain.com' }
    assert_redirected_to edit_domain_blacklist_path(domain)
    assert_equal 'Unable to update blacklisted domain', flash[:error]
  end

  test 'delete domain link deletes domain' do
    create_two_blacklisted_domains
    domain = DomainBlacklist.find_by_domain('bad_domain.com')
    delete :destroy, id: domain.id
    assert_redirected_to domain_blacklists_path
    assert_equal 1, DomainBlacklist.count
    assert_equal 'Blacklisted Domain successfully deleted', flash[:notice]
  end

  test 'the sidebar should have domain blacklists selected' do
    skip('TODO: sidebar')
    create_two_blacklisted_domains
    login_as(:jason)
    get :index
    assert_select 'li', class: 'active' do
      assert_select 'a', href: 'domain_blacklists', text: 'Blacklist Domains'
    end
  end

  def create_two_blacklisted_domains
    DomainBlacklist.create(domain: 'bad_domain.com')
    DomainBlacklist.create(domain: 'spam_domain.com')
    assert_equal 2, DomainBlacklist.count
  end
end
