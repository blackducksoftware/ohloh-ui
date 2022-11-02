# frozen_string_literal: true

require 'test_helper'

class ProjectTagsControllerTest < ActionController::TestCase
  describe 'index' do
    it 'should show the current projects tags and related projects' do
      project1 = create(:project, name: 'Red')
      project2 = create(:project, name: 'Apple')
      project3 = create(:project, name: 'Blue')
      tag = create(:tag, name: 'color')
      create(:tagging, tag: tag, taggable: project1)
      create(:tagging, tag: tag, taggable: project3)
      get :index, params: { project_id: project1.to_param }
      assert_response :success
      assert_select "#related_project_#{project1.to_param}", 0
      assert_select "#related_project_#{project2.to_param}", 0
      assert_select "#related_project_#{project3.to_param}", 1
      _(response.body).must_match 'color'
    end

    it 'should give an alert if there are no tags associated with the project' do
      project = create(:project)
      get :index, params: { project_id: project.to_param }
      assert_response :success
      assert_select '.alert', 2
      _(response.body).must_match I18n.t('project_tags.index.no_other_projects')
    end
  end

  describe 'create' do
    it 'should require a current user' do
      project = create(:project)
      login_as nil
      post :create, params: { project_id: project.to_param, tag_name: 'scrumptious' }
      assert_response :redirect
      assert_redirected_to new_session_path
      _(project.reload.tag_list).must_equal ''
    end

    it 'should disallow non-managers from editing the project tag list' do
      project = create(:project)
      create(:permission, target: project, remainder: true)
      login_as create(:account)
      post :create, params: { project_id: project.to_param, tag_name: 'luscious' }
      assert_response :unauthorized
      _(project.reload.tag_list).must_equal ''
    end

    it 'should persist tags' do
      project = create(:project)
      login_as create(:account)
      post :create, params: { project_id: project.to_param, tag_name: 'tasty' }
      assert_response :ok
      _(project.reload.tag_list).must_equal 'tasty'
    end

    it 'should gracefully handle attempting to add the same tag twice' do
      project = create(:project)
      project.tag_list = 'zesty'
      login_as create(:account)
      post :create, params: { project_id: project.to_param, tag_name: 'zesty' }
      assert_response :ok
      _(project.reload.tag_list).must_equal 'zesty'
    end

    it 'should gracefully handle attempting to add garbage' do
      project = create(:project)
      login_as create(:account)
      post :create, params: { project_id: project.to_param, tag_name: '$π@µµé®' }
      assert_response :unprocessable_entity
      _(project.reload.tag_list).must_equal ''
    end

    it 'should return status 422 and project edit url if project description is invalid' do
      project = create(:project_with_invalid_description)
      login_as create(:account)
      post :create, params: { project_id: project.to_param, tag_name: 'zesty' }
      assert_response 422
      _(@response.body).must_match 'too long'
    end
  end

  describe 'destroy' do
    it 'should require a current user' do
      project = create(:project)
      create(:tagging, taggable: project, tag: create(:tag, name: 'shiny'))
      login_as nil
      delete :destroy, params: { project_id: project.to_param, id: 'shiny' }
      assert_response :redirect
      assert_redirected_to new_session_path
      _(project.reload.tag_list).must_equal 'shiny'
    end

    it 'should disallow non-managers from editing the project tag list' do
      project = create(:project)
      create(:tagging, taggable: project, tag: create(:tag, name: 'matte'))
      create(:permission, target: project, remainder: true)
      login_as create(:account)
      delete :destroy, params: { project_id: project.to_param, id: 'matte' }
      assert_response :unauthorized
      _(project.reload.tag_list).must_equal 'matte'
    end

    it 'should persist tags' do
      project = create(:project)
      create(:tagging, taggable: project, tag: create(:tag, name: 'glossy'))
      login_as create(:account)
      delete :destroy, params: { project_id: project.to_param, id: 'glossy' }
      assert_response :ok
      _(project.reload.tag_list).must_equal ''
    end
  end

  describe 'related' do
    it 'should show the current projects related projects' do
      project1 = create(:project, name: 'Red')
      project2 = create(:project, name: 'Apple')
      project3 = create(:project, name: 'Blue')
      tag = create(:tag, name: 'color')
      create(:tagging, tag: tag, taggable: project1)
      create(:tagging, tag: tag, taggable: project3)
      get :related, params: { project_id: project1.to_param }
      assert_response :success
      assert_select "#related_project_#{project1.to_param}", 0
      assert_select "#related_project_#{project2.to_param}", 0
      assert_select "#related_project_#{project3.to_param}", 1
      _(response.body).must_match 'color'
    end
  end

  describe 'status' do
    it 'should return how many tags can be added' do
      project = create(:project)
      create(:tagging, taggable: project, tag: create(:tag, name: 'glossy'))
      login_as create(:account)
      get :status, params: { project_id: project.to_param }
      assert_response :ok
      resp = JSON.parse(response.body)
      remaining = Tag::MAX_ALLOWED_PER_PROJECT - 1
      _(resp[0]).must_equal remaining
      _(resp[1]).must_equal I18n.t('tags.number_remaining', count: remaining, word: I18n.t('tags.tag').pluralize)
    end
  end
end
