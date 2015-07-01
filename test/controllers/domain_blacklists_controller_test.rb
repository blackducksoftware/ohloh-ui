require_relative '../test_helper'

class DomainBlacklistsControllerTest < ActionController::TestCase
  def setup
    login_as create(:admin)
  end

  it 'index requires login' do
    login_as nil
    get :index
    must_respond_with :redirect
    must_redirect_to new_session_path
  end

  it 'index requires admin' do
    login_as create(:account)
    get :index
    must_respond_with :unauthorized
  end

  it 'index without domains has notice' do
    login_as create(:admin)
    get :index
    assert_select 'div.alert'
    response.body.must_match I18n.t('domain_blacklists.index.notice')
  end

  it 'index' do
    get :index
    must_respond_with :success
    assert_select 'h3', text: 'Blacklist Domains'
    assert_select 'a[href="/domain_blacklists/new"]', text: 'Add New Domain'
  end

  it 'link to add new domain' do
    get :index
    must_respond_with :success
    assert_select 'h3', text: 'Blacklist Domains'
    assert_select 'a[href="/domain_blacklists/new"]', text: 'Add New Domain'
  end

  it 'new domain page form has new domain field' do
    get :new
    must_respond_with :success
    assert_select 'h1', text: 'Add New Domain Blacklist'
    assert_select 'form[action="/domain_blacklists"]'
    assert_select 'label[for=domain_blacklist_domain]', text: 'New Domain to Blacklist:'
    assert_select 'input[id=domain_blacklist_domain]', type: 'text'
    assert_select 'input[name=commit]', type: 'submit'
  end

  it 'posting the form with a new domain should create a new record' do
    DomainBlacklist.count.must_equal 0
    post :create, domain_blacklist: { domain: 'mindpowerup.com' }
    assigns(:domain_blacklist).wont_be_nil
    assigns(:domain_blacklist).errors.count.must_equal 0
    flash[:success].must_equal 'Domain successfully added to blacklist'
    DomainBlacklist.count.must_equal 1
    assert_redirected_to domain_blacklists_path
  end

  it 'posting the form with an existing domain fails' do
    bad_domain = 'cruddysite.com'
    DomainBlacklist.create(domain: bad_domain)
    DomainBlacklist.count.must_equal 1
    post :create, domain_blacklist: { domain: bad_domain }
    assigns(:domain_blacklist).wont_be_nil
    assigns(:domain_blacklist).errors.count.must_equal 1
    flash[:error].must_equal 'Unable to add domain to blacklist'
    DomainBlacklist.count.must_equal 1
    assert_redirected_to new_domain_blacklist_path
  end

  it 'index show list of blacklisted domains' do
    create_two_blacklisted_domains
    get :index
    assert_select 'td', text: 'bad_domain.com'
    assert_select 'td', text: 'spam_domain.com'
  end

  it 'index table has edit and delete links' do
    create_two_blacklisted_domains
    bad = DomainBlacklist.find_by_domain('bad_domain.com')
    get :index
    assert_select 'tr' do
      assert_select 'td', text: 'bad_domain.com'
      assert_select 'td' do
        assert_select "a[href='#{edit_domain_blacklist_path(bad)}']", text: 'Edit'
        assert_select "a[href='#{domain_blacklist_path(bad)}']", text: 'Delete'
      end
    end
  end

  it 'edit domain page allows edit' do
    create_two_blacklisted_domains
    domain = DomainBlacklist.find_by_domain('bad_domain.com')
    get :edit, id: domain.id
    must_respond_with :success
    assert_select "form[action='#{domain_blacklist_path(domain)}'][method=post]" do
      assert_select 'label', text: 'Blacklisted Domain'
      assert_select "input[value='#{domain.domain}']"
      assert_select 'input[type="submit"][value="Update Domain"]'
    end
  end

  it 'update updates a blacklisted domain' do
    create_two_blacklisted_domains
    domain = DomainBlacklist.find_by_domain('bad_domain.com')
    put :update, id: domain.id, domain_blacklist: { 'domain' => 'really_bad_domain.com' }
    assert_redirected_to domain_blacklists_path
    domain.reload
    assert domain.domain == 'really_bad_domain.com'
  end

  it 'update when the new name is a conflict shows an error message' do
    create_two_blacklisted_domains
    domain = DomainBlacklist.find_by_domain('bad_domain.com')
    put :update, id: domain.id, domain_blacklist: { 'domain' => 'spam_domain.com' }
    assert_redirected_to edit_domain_blacklist_path(domain)
    flash[:error].must_equal 'Unable to update blacklisted domain'
  end

  it 'delete domain link deletes domain' do
    create_two_blacklisted_domains
    domain = DomainBlacklist.find_by_domain('bad_domain.com')
    delete :destroy, id: domain.id
    assert_redirected_to domain_blacklists_path
    DomainBlacklist.count.must_equal 1
    flash[:notice].must_equal 'Blacklisted Domain successfully deleted'
  end

  it 'the sidebar should have domain blacklists selected' do
    create_two_blacklisted_domains
    login_as create(:admin)
    get :index
    assert_select 'div', class: 'status' do
      assert_select 'h3', text: 'Blacklist Domains'
    end
  end

  def create_two_blacklisted_domains
    DomainBlacklist.create(domain: 'bad_domain.com')
    DomainBlacklist.create(domain: 'spam_domain.com')
    DomainBlacklist.count.must_equal 2
  end
end
