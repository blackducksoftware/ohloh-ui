# frozen_string_literal: true

require 'test_helper'

class Admin::OrganizationsControllerTest < ActionController::TestCase
  let(:admin) { create(:admin) }
  let(:account) { create(:account) }
  let(:organization) { create(:organization) }

  before do
    login_as admin
  end

  it 'should render index page' do
    create(:organization)
    get :index
    assert_response :success
  end

  it 'should edit the account' do
    account.update_column(:level, 10)
    login_as account
    org = create(:organization, name: 'test', vanity_url: 'test')
    put :update, params: { id: org.vanity_url, organization: { name: 'test2', description: 'tes', vanity_url: 'test',
                                                               org_type: '2', homepage_url: 'http://test.com' } }

    _(assigns(:organization).name).must_equal 'test2'
    _(assigns(:organization).valid?).must_equal true
  end
end
