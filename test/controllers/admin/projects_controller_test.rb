# frozen_string_literal: true

require 'test_helper'

class Admin::ProjectsControllerTest < ActionController::TestCase
  let(:admin) { create(:admin) }
  let(:account) { create(:account) }
  let(:project) { create(:project) }

  before do
    login_as admin
  end

  it 'should render index page' do
    create(:project)
    get :index
    assert_response :success
  end

  it 'should edit the account' do
    account.update_column(:level, 10)
    login_as account
    project = create(:project, name: 'test', vanity_url: 'test')
    put :update, params: { id: project.vanity_url }

    _(assigns(:project).name).must_equal 'test'
    _(assigns(:project).valid?).must_equal true
  end

  it 'edit should populate the form' do
    account.update_column(:level, 10)
    login_as account
    project = create(:project, name: 'test', vanity_url: 'test')
    get :edit, params: { id: project.vanity_url }
    assert_response :ok
  end
end
