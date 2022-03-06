# frozen_string_literal: true

require 'test_helper'

class SessionProjectsControllerTest < ActionController::TestCase
  let(:project) { create(:project) }

  describe 'index' do
    it 'must render successfully' do
      get :index, xhr: true

      assert_response :success
    end

    it 'must prevent bot access' do
      ApplicationController.any_instance.stubs(:bot?).returns(true)

      get :index, xhr: true

      assert_response :forbidden
    end
  end

  describe 'create' do
    it 'must render successfully' do
      post :create, params: { project_id: project.to_param }, xhr: true

      assert_response :success

      _(session[:session_projects]).must_equal [project.to_param]
      assert_select "form#sp_frm_#{project.to_param}"
    end

    it 'must prevent bot access' do
      ApplicationController.any_instance.stubs(:bot?).returns(true)

      post :create, params: { project_id: project.to_param }, xhr: true

      assert_response :forbidden

      _(response.body).must_equal ''
      _(session[:session_projects]).must_be_nil
    end

    it 'wont store duplicates in session' do
      session[:session_projects] = [project.to_param]
      post :create, params: { project_id: project.to_param }, xhr: true

      assert_response :success

      _(session[:session_projects]).must_equal [project.to_param]
    end

    it 'wont store non existent project' do
      _(-> { post :create, params: { project_id: 'not_found' }, xhr: true }).must_raise(ActiveRecord::RecordNotFound)
      _(session[:session_projects]).must_be_nil
    end

    it 'must remove non existent projects in session' do
      session[:session_projects] = ['does_not_exist']
      post :create, params: { project_id: project.to_param }, xhr: true

      assert_response :success
      _(session[:session_projects]).must_equal [project.to_param]
    end

    it 'must allow three projects in session' do
      project2 = create(:project)
      project3 = create(:project)
      session[:session_projects] = [project2.to_param, project3.to_param]
      post :create, params: { project_id: project.to_param }, xhr: true

      assert_response :success

      _(session[:session_projects]).must_equal [project2.to_param, project3.to_param, project.to_param]
    end

    it 'wont allow a new project when session already has 3 projects' do
      project2 = create(:project)
      project3 = create(:project)
      project4 = create(:project)
      session[:session_projects] = [project2.to_param, project3.to_param, project4.to_param]

      post :create, params: { project_id: project.to_param }, xhr: true
      assert_response :forbidden

      _(session[:session_projects]).must_equal [project2.to_param, project3.to_param, project4.to_param]
    end
  end

  describe 'destroy' do
    it 'must successfully remove a project from session' do
      project2 = create(:project)
      project3 = create(:project)
      project4 = create(:project)
      session[:session_projects] = [project2.to_param, project3.to_param, project4.to_param]
      delete :destroy, params: { id: project3.to_param }, xhr: true

      assert_response :success

      _(session[:session_projects]).must_equal [project2.to_param, project4.to_param]
      _(assigns[:session_projects]).must_equal [project2, project4]
    end

    it 'must prevent bot access' do
      ApplicationController.any_instance.stubs(:bot?).returns(true)

      delete :destroy, params: { id: project.to_param }, xhr: true

      assert_response :forbidden
      _(session[:session_projects]).must_be_nil
    end

    it 'wont fail when session has no projects' do
      delete :destroy, params: { id: project.to_param }, xhr: true

      assert_response :success
      _(session[:session_projects]).must_equal []
    end
  end
end
