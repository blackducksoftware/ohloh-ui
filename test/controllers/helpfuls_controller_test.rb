require 'test_helper'

class HelpfulsControllerTest < ActionController::TestCase
  fixtures :accounts, :projects
  def setup
    @linux_review = projects(:linux).reviews.create!(title: 'T', comment: 'C', account_id: accounts(:admin).id)
  end

  def test_login_required
    login_as nil
    create_helpful(true)
    assert_response :unauthorized
  end

  def test_create_review_helpful
    login_as accounts(:user)
    assert_difference 'Helpful.count' do
      create_helpful(true)
      assert_response :success
      json = JSON.parse(@response.body)
      assert_equal 1, json['yes']
      assert_equal 1, json['total']
    end
  end

  def test_create_review_not_helpful
    login_as accounts(:user)
    assert_difference 'Helpful.count' do
      create_helpful(false)
      assert_response :success
      json = JSON.parse(@response.body)
      assert_equal 0, json['yes']
      assert_equal 1, json['total']
    end
  end

  def test_bug_fix_on_multiple_helpfuls
    Helpful.create(review_id: @linux_review.id, account_id: accounts(:user).id, yes: false)
    login_as accounts(:joe)
    assert_difference 'Helpful.count' do
      create_helpful(true)
      assert_response :success
      json = JSON.parse(@response.body)
      assert_equal 1, json['yes']
      assert_equal 2, json['total']
    end
  end

  def test_cant_helpful_yourself
    login_as accounts(:admin)
    assert_no_difference 'Helpful.count' do
      create_helpful(true)
      assert_response :success
      json = JSON.parse(@response.body)
      assert_equal 0, json['yes']
      assert_equal 0, json['total']
    end
  end

  def test_project_must_exist
    login_as accounts(:user)
    post :create, project_id: 'I_AM_A_BANANA!', review_id: @linux_review.id,
                  format: 'json', helpful: { yes: true }
    assert_response :not_found
  end

  def test_review_must_exist
    login_as accounts(:user)
    post :create, project_id: projects(:linux).to_param, review_id: 123_456_789,
                  format: 'json', helpful: { yes: true }
    assert_response :not_found
  end

  def test_review_must_match_project
    login_as accounts(:user)
    post :create, project_id: projects(:adium).to_param, review_id: @linux_review.id,
                  format: 'json', helpful: { yes: true }
    assert_response :not_found
  end

  private

  def create_helpful(helpful)
    post :create, project_id: projects(:linux).to_param, review_id: @linux_review.id,
                  format: 'json', helpful: { yes: helpful }
  end
end
