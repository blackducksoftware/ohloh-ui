# frozen_string_literal: true

require 'test_helper'

class ProjectLicensesControllerTest < ActionController::TestCase
  # index
  it 'index should work for projects with no licenses' do
    project = create(:project)
    login_as nil
    get :index, params: { project_id: project.to_param }
    assert_response :ok
    assert_select '#flash-msg .alert', 1
    assert_select 'tr.license', 0
    assert_select 'a.new-license', 1
    assert_select 'a.new-license.needs_login', 1
    assert_select 'a.new-license.disabled', 0
  end

  it 'index should work for projects with licenses' do
    project = create(:project)
    create(:project_license, project: project)
    create(:project_license, project: project)
    create(:project_license, project: project)
    login_as nil
    get :index, params: { project_id: project.to_param }
    assert_response :ok
    _(flash[:notice]).must_equal I18n.t('permissions.must_log_in')
    assert_select '#flash-msg .alert', 1
    assert_select 'tr.license', 3
    assert_select 'a.new-license', 1
    assert_select 'a.new-license.needs_login', 1
    assert_select 'a.new-license.disabled', 0
  end

  it 'index sort licenses by vanity_url' do
    project = create(:project)
    license1 = create(:project_license, project: project)
    license2 = create(:project_license, project: project)
    license3 = create(:project_license, project: project)

    sorted_licenses = [license1, license2, license3].sort { |a, b| a.license.vanity_url <=> b.license.vanity_url }

    login_as nil

    get :index, params: { project_id: project.to_param }
    assert_response :ok
    _(assigns(:project_licenses)).must_equal sorted_licenses
  end

  it 'index should offer to allow adding licenses for logged in users' do
    project = create(:project)
    create(:project_license, project: project)
    create(:project_license, project: project)
    create(:project_license, project: project)
    login_as create(:account)
    get :index, params: { project_id: project.to_param }
    assert_response :ok
    assert_select 'a.new-license', 1
    assert_select 'a.new-license.needs_login', 0
    assert_select 'a.new-license.disabled', 0
  end

  it 'index should not offer to allow adding licenses for non-managers' do
    project = create(:project)
    create(:project_license, project: project)
    create(:project_license, project: project)
    create(:project_license, project: project)
    create(:permission, target: project, remainder: true)
    login_as create(:account)
    get :index, params: { project_id: project.to_param }
    assert_response :ok
    assert_select 'a.new-license', 1
    assert_select 'a.new-license.needs_login', 0
    assert_select 'a.new-license.disabled', 1
  end

  # new
  it 'new should offer to allow adding license for logged in users' do
    project = create(:project)
    login_as create(:account)
    get :new, params: { project_id: project.to_param }
    assert_response :ok
    assert_select 'input.add-license', 1
    assert_select 'a.add-license.needs_login', 0
    assert_select 'a.add-license.disabled', 0
  end

  it 'new should not offer to allow adding license for non-managers' do
    project = create(:project)
    create(:permission, target: project, remainder: true)
    login_as create(:account)
    get :new, params: { project_id: project.to_param }
    assert_response :ok
    assert_select 'input.add-license', 0
    assert_select 'a.add-license.needs_login', 0
    assert_select 'a.add-license.disabled', 1
  end

  it 'new should not offer to allow adding license for unlogged users' do
    project = create(:project)
    login_as nil
    get :new, params: { project_id: project.to_param }
    assert_response :ok
    assert_select 'input.add-license', 0
    assert_select 'a.add-license.needs_login', 1
    assert_select 'a.add-license.disabled', 0
  end

  # create
  it 'create should require a current user' do
    project = create(:project)
    license = create(:license)
    login_as nil
    post :create, params: { project_id: project.to_param, license_id: license.id }
    assert_response :found
    _(project.reload.licenses.pluck(:id)).must_equal []
    _(flash['notice']).must_match I18n.t(:not_authorized)
  end

  it 'create should deny changes to non-managers' do
    project = create(:project)
    create(:permission, target: project, remainder: true)
    license = create(:license)
    login_as create(:account)
    post :create, params: { project_id: project.to_param, license_id: license.id }
    assert_response :found
    _(project.reload.licenses.pluck(:id)).must_equal []
    _(flash['notice']).must_match I18n.t(:not_authorized)
  end

  it 'create should accept good parameters' do
    project = create(:project)
    license = create(:license)
    login_as create(:account)
    post :create, params: { project_id: project.to_param, license_id: license.id }
    assert_response :found
    _(project.reload.licenses.pluck(:id)).must_equal [license.id]
    _(flash['success']).must_match I18n.t('project_licenses.create.success')
  end

  it 'create should gracefully handle garbage parameters' do
    project = create(:project)
    login_as create(:account)
    post :create, params: { project_id: project.to_param, license_id: 'i_am_a_banana' }
    assert_response :unprocessable_entity
    _(project.reload.licenses.pluck(:id)).must_equal []
    _(response.body).must_match I18n.t('project_licenses.create.error_other')
  end

  it 'create should gracefully handle attempting adding a license that is already on the project' do
    project = create(:project)
    license = create(:license)
    create(:project_license, project: project, license: license)
    login_as create(:account)
    post :create, params: { project_id: project.to_param, license_id: license.id }
    assert_response :unprocessable_entity
    _(project.reload.licenses.pluck(:id)).must_equal [license.id]
    _(response.body).must_match I18n.t('project_licenses.create.error_already_exists')
  end

  it 'create should reuse a previously deleted project_license if one is available' do
    project = create(:project)
    license = create(:license)
    project_license = create(:project_license, project: project, license: license)
    project_license.destroy
    login_as create(:account)
    post :create, params: { project_id: project.to_param, license_id: license.id }
    assert_response :found
    _(project.reload.project_licenses.pluck(:id)).must_equal [project_license.id]
    _(flash['success']).must_match I18n.t('project_licenses.create.success')
  end

  # destroy
  it 'destroy should require a current user' do
    project = create(:project)
    project_license = create(:project_license, project: project)
    login_as nil
    delete :destroy, params: { project_id: project.to_param, id: project_license.id }
    assert_response :found
    _(project.reload.project_licenses.pluck(:id)).must_equal [project_license.id]
    _(flash['notice']).must_match I18n.t(:not_authorized)
  end

  it 'destroy should deny changes to non-managers' do
    project = create(:project)
    project_license = create(:project_license, project: project)
    create(:permission, target: project, remainder: true)
    login_as create(:account)
    delete :destroy, params: { project_id: project.to_param, id: project_license.id }
    assert_response :found
    _(project.reload.project_licenses.pluck(:id)).must_equal [project_license.id]
    _(flash['notice']).must_match I18n.t(:not_authorized)
  end

  it 'destroy should accept good parameters' do
    project = create(:project)
    project_license = create(:project_license, project: project)
    login_as create(:account)
    delete :destroy, params: { project_id: project.to_param, id: project_license.id }
    assert_response :found
    _(project.reload.project_licenses.pluck(:id)).must_equal []
    _(flash['notice']).must_match I18n.t('project_licenses.destroy.success')
  end

  it 'destroy should gracefully handle garbage parameters' do
    project = create(:project)
    project_license = create(:project_license, project: project)
    login_as create(:account)
    ProjectLicense.any_instance.expects(:destroy).returns false
    delete :destroy, params: { project_id: project.to_param, id: project_license.id }
    assert_response :found
    _(project.reload.project_licenses.pluck(:id)).must_equal [project_license.id]
    _(flash['notice']).must_match I18n.t('project_licenses.destroy.error')
  end
end
