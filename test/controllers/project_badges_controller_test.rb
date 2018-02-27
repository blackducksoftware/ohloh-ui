require 'test_helper'

describe 'ProjectBadgesController' do
  before do
    @enlistment = create(:enlistment)
    @project = @enlistment.project
    @project_id = @project.vanity_url
    @account = create(:account)
    @proj_badge_build = build(:project_badge,
                              enlistment: @enlistment,
                              type: 'CiiBadge').attributes
  end

  describe 'index' do
    it 'Should render index template for valid project' do
      Enlistment.any_instance.stubs(:code_location).returns(code_location_stub_with_id)
      get :index, project_id: @project_id
      assert_response :success
    end
  end

  describe 'create' do
    it 'Should redirect if user is not logged in' do
      post :create, project_id: @project_id,
                    project_badge: @proj_badge_build
      must_redirect_to new_session_path
    end

    it 'Should not allow unauthorized users to create' do
      create(:permission, target: @project, remainder: true)
      login_as create(:account)
      post :create, project_id: @project_id,
                    project_badge: @proj_badge_build
      assert_response :unauthorized
    end

    it 'Should not create ciibadge if url empty' do
      Enlistment.any_instance.stubs(:code_location).returns(code_location_stub)
      login_as @account
      post :create, project_id: @project_id,
                    project_badge: build(:project_badge,
                                         enlistment: @enlistment,
                                         type: 'CiiBadge',
                                         identifier: '',
                                         status: 1).attributes
      must_render_template :index
      @project.project_badges.size.must_equal 0
    end

    it 'Should create badge if user is logged in and correct badge param is passed' do
      Enlistment.any_instance.stubs(:code_location).returns(code_location_stub)
      login_as @account
      post :create, project_id: @project_id,
                    project_badge: build(:project_badge,
                                         enlistment: @enlistment,
                                         type: 'CiiBadge',
                                         identifier: '1',
                                         status: 1).attributes
      must_redirect_to action: :index
      flash[:success].must_be :present?
      @project.project_badges.size.must_equal 1
    end

    it 'should redirect if project badge is already present' do
      Enlistment.any_instance.stubs(:code_location).returns(code_location_stub)
      login_as @account
      @project_badge = create(:project_badge,
                              enlistment: @enlistment,
                              type: 'CiiBadge',
                              identifier: '1',
                              status: 1)
      post :create, project_id: @project_id,
                    project_badge: build(:project_badge,
                                         enlistment: @enlistment,
                                         type: 'CiiBadge',
                                         identifier: '1',
                                         status: 1).attributes
      must_redirect_to action: :index
    end
  end

  describe 'update' do
    it 'should be successful for valid edit param' do
      @project_badge = create(:project_badge,
                              enlistment: @enlistment,
                              type: 'CiiBadge',
                              identifier: '1',
                              status: 1)
      login_as create(:account)
      patch :update, project_id: @project_id, id: @project_badge.id, project_badge: { identifier: '5' }
      response_body = JSON.parse(@response.body)
      response_body['success'].must_equal true
      response_body['value'].must_equal '5'
      assert_response :success
    end

    it 'should be unsuccessfill for in valid edit param' do
      @project_badge = create(:project_badge,
                              enlistment: @enlistment,
                              type: 'CiiBadge',
                              identifier: '1',
                              status: 1)
      login_as create(:account)
      patch :update, project_id: @project_id, id: @project_badge.id, project_badge: { identifier: '' }
      response_body = JSON.parse(@response.body)
      response_body['success'].must_equal false
      assert_response :success
    end
  end

  describe 'destroy' do
    it 'Should not soft delete a badge if use is not logged in' do
      project_badge = create(:project_badge,
                             enlistment: @enlistment,
                             type: 'CiiBadge',
                             identifier: '1')
      create(:permission, target: @project, remainder: true)
      login_as create(:account)
      delete :destroy, project_id: @project_id, id: project_badge.id
      assert_response :unauthorized
    end

    it 'should soft delete the badge if authorized user sends delete request' do
      project_badge = create(:project_badge,
                             enlistment: @enlistment,
                             type: 'CiiBadge',
                             identifier: '1')
      login_as @account
      delete :destroy, project_id: @project_id, id: project_badge.id
      flash[:success].must_be :present?
      must_redirect_to action: :index
    end
  end
end
