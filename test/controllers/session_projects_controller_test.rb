# frozen_string_literal: true

require 'test_helper'

describe 'SessionProjectsController' do
  let(:project) { create(:project) }

  describe 'index' do
    it 'must render successfully' do
      xhr :get, :index

      must_respond_with :success
    end

    it 'must prevent bot access' do
      ApplicationController.any_instance.stubs(:bot?).returns(true)

      xhr :get, :index

      must_respond_with :forbidden
    end
  end

  describe 'create' do
    it 'must render successfully' do
      xhr :post, :create, project_id: project.to_param

      must_respond_with :success

      session[:session_projects].must_equal [project.to_param]
      assert_select "form#sp_frm_#{project.to_param}"
    end

    it 'must prevent bot access' do
      ApplicationController.any_instance.stubs(:bot?).returns(true)

      xhr :post, :create, project_id: project.to_param

      must_respond_with :forbidden

      response.body.must_equal ''
      assert_nil session[:session_projects]
    end

    it 'wont store duplicates in session' do
      session[:session_projects] = [project.to_param]
      xhr :post, :create, project_id: project.to_param

      must_respond_with :success

      session[:session_projects].must_equal [project.to_param]
    end

    it 'wont store non existent project' do
      -> { xhr :post, :create, project_id: 'not_found' }.must_raise(ActiveRecord::RecordNotFound)
      session[:session_projects].must_be_nil
    end

    it 'must remove non existent projects in session' do
      session[:session_projects] = ['does_not_exist']
      xhr :post, :create, project_id: project.to_param

      must_respond_with :success
      session[:session_projects].must_equal [project.to_param]
    end

    it 'must allow three projects in session' do
      project2 = create(:project)
      project3 = create(:project)
      session[:session_projects] = [project2.to_param, project3.to_param]
      xhr :post, :create, project_id: project.to_param

      must_respond_with :success

      session[:session_projects].must_equal [project2.to_param, project3.to_param, project.to_param]
    end

    it 'wont allow a new project when session already has 3 projects' do
      project2 = create(:project)
      project3 = create(:project)
      project4 = create(:project)
      session[:session_projects] = [project2.to_param, project3.to_param, project4.to_param]

      xhr :post, :create, project_id: project.to_param
      must_respond_with :forbidden

      session[:session_projects].must_equal [project2.to_param, project3.to_param, project4.to_param]
    end
  end

  describe 'destroy' do
    it 'must successfully remove a project from session' do
      project2 = create(:project)
      project3 = create(:project)
      project4 = create(:project)
      session[:session_projects] = [project2.to_param, project3.to_param, project4.to_param]
      xhr :delete, :destroy, id: project3.to_param

      must_respond_with :success

      session[:session_projects].must_equal [project2.to_param, project4.to_param]
      assigns[:session_projects].must_equal [project2, project4]
    end

    it 'must prevent bot access' do
      ApplicationController.any_instance.stubs(:bot?).returns(true)

      xhr :delete, :destroy, id: project.to_param

      must_respond_with :forbidden
      assert_nil session[:session_projects]
    end

    it 'wont fail when session has no projects' do
      xhr :delete, :destroy, id: project.to_param

      must_respond_with :success
      session[:session_projects].must_equal []
    end
  end
end
