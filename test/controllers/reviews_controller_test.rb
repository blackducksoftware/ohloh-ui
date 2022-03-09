# frozen_string_literal: true

require 'test_helper'

class ReviewsControllerTest < ActionController::TestCase
  let(:review) { create(:review) }
  let(:project) { review.project }
  let(:account) { review.account }

  describe 'index' do
    it 'should raise exception when parent id is null' do
      assert_raises ActionController::UrlGenerationError do
        get :index
      end
    end

    it 'should not return for invalid project id' do
      get :index, params: { project_id: 'NULL' }
      assert_response :not_found
    end

    it 'should return for project id' do
      get :index, params: { project_id: project.to_param }
      assert_template :index
      assert_response :success
      _(assigns(:reviews).count).must_equal 1
      _(assigns(:reviews).first).must_equal review
    end

    it 'should return for filter by query string' do
      get :index, params: { project_id: project.to_param, query: review.title }
      _(assigns(:reviews).count).must_equal 1
      _(assigns(:reviews).first).must_equal review
    end

    it 'should return for sort by' do
      project_review = create(:review, project: project, title: review.title)
      get :index, params: { project_id: project.to_param, query: review.title, sort: 'recently_added' }
      _(assigns(:reviews).count).must_equal 2
      _(assigns(:reviews).first).must_equal project_review
      _(assigns(:reviews).second).must_equal review
    end

    it 'should not return for null query string' do
      get :index, params: { project_id: project.to_param, query: 'NULL' }
      _(assigns(:reviews).count).must_equal 0
      _(assigns(:reviews).first).must_be_nil
    end

    it 'should return for account id' do
      account = create(:account)
      account_review = create(:review, account: account)
      get :index, params: { account_id: account.to_param }
      _(assigns(:reviews).count).must_equal 1
      _(assigns(:reviews).first).must_equal account_review
    end

    it 'must render projects/deleted when project is deleted' do
      project = create(:project)

      project.update!(deleted: true, editor_account: create(:account))

      get :index, params: { project_id: project.to_param }

      assert_template 'deleted'
    end
  end

  describe 'summary' do
    it 'should return recently_added and most_helpful_reviews' do
      4.times { create(:review, project: project) }
      get :summary, params: { project_id: project.to_param }
      assert_response :success
      assert_template :summary
      most_helpful_reviews = assigns(:most_helpful_reviews)
      recent_reviews = assigns(:recent_reviews)
      _(most_helpful_reviews.count).must_equal 5
      _(most_helpful_reviews.first).must_equal review
      _(recent_reviews.count).must_equal 5
      _(recent_reviews.last).must_equal review
      _(assigns(:account_reviews)).must_be_nil
    end

    it 'should return account_review when user logged-in' do
      login_as(account)
      get :summary, params: { project_id: project.to_param }
      assert_response :success
      assert_template :summary
      _(assigns(:account_reviews).first).must_equal review
    end
  end

  describe 'new' do
    it 'should return unauthorized when user not logged-in' do
      get :new, params: { project_id: project.to_param }
      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'should allow access when user logged-in' do
      login_as account
      rating = create(:rating, account: account, project: project)
      get :new, params: { project_id: project.to_param }
      assert_response :success
      assert_template :new
      _(assigns(:rating)).must_equal rating
    end
  end

  describe 'edit' do
    it 'should restrict when user not logged-in' do
      get :edit, params: { id: review.id, project_id: project.to_param }
      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'should allow when user logged-in' do
      login_as account
      rating = create(:rating, account: account, project: project)
      get :edit, params: { id: review.id, project_id: project.to_param }
      assert_response :success
      assert_template :edit
      _(assigns(:rating)).must_equal rating
    end

    it 'should allow to edit only his records' do
      login_as create(:account)
      get :edit, params: { id: review.id, project_id: project.to_param }
      assert_response :redirect
      assert_redirected_to summary_project_reviews_path(project)
    end
  end

  describe 'update' do
    it 'should update when user logged in' do
      review.title = 'New value'
      login_as account
      post :update, params: { id: review.id, project_id: project.to_param, review: review.attributes }
      assert_response :redirect
      assert_redirected_to summary_project_reviews_path(project)
      assigns(:review).title = 'New value'
    end

    it 'update allow to update only his records' do
      title = review.title
      review.title = 'New value'
      login_as account
      post :update, params: { id: review.id, project_id: project.to_param, review: review.attributes }
      assert_response :redirect
      assert_redirected_to summary_project_reviews_path(project)
      assigns(:review).title = title
    end

    it 'should render edit if update fails' do
      login_as account
      Review.any_instance.stubs(:update).returns(false)
      post :update, params: { id: review.id, project_id: project.to_param, review: review.attributes }
      assert_response :ok
      assert_template :edit
    end
  end

  describe 'destroy' do
    it 'should delete review' do
      login_as account
      before = Review.count
      delete :destroy, params: { id: review.id }
      _(Review.count).must_equal(before - 1)
    end
  end

  describe 'create' do
    it 'should allow to create only if user logged-in' do
      login_as create(:account)
      project.reload
      before = Review.count
      post :create, params: { project_id: project.to_param, review: review.attributes }
      assert_redirected_to summary_project_reviews_path(project)
      _(Review.count).must_equal(before + 1)
    end

    it 'should return error if create fails' do
      login_as account
      Review.any_instance.stubs(:save).returns(false)
      before = Review.count
      post :create, params: { project_id: project.to_param, review: review.attributes }
      assert_response :ok
      assert_template :new
      _(Review.count).must_equal before
    end
  end
end
