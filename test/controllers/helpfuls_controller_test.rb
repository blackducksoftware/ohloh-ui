require 'test_helper'

class HelpfulsControllerTest < ActionController::TestCase
  def setup
    @admin = create(:admin)
    @linux_review = projects(:linux).reviews.create!(title: 'T', comment: 'C', account_id: @admin.id)
  end

  it 'test login required' do
    login_as nil
    create_helpful(true)
    must_respond_with :unauthorized
  end

  it 'test create review helpful' do
    login_as create(:account)
    assert_difference 'Helpful.count' do
      create_helpful(true)
      must_respond_with :success
      json = JSON.parse(@response.body)
      json['yes'].must_equal 1
      json['total'].must_equal 1
    end
  end

  it 'test create review not helpful' do
    login_as create(:account)
    assert_difference 'Helpful.count' do
      create_helpful(false)
      must_respond_with :success
      json = JSON.parse(@response.body)
      json['yes'].must_equal 0
      json['total'].must_equal 1
    end
  end

  it 'test bug fix on multiple helpfuls' do
    Helpful.create(review_id: @linux_review.id, account_id: create(:account).id, yes: false)
    login_as accounts(:joe)
    assert_difference 'Helpful.count' do
      create_helpful(true)
      must_respond_with :success
      json = JSON.parse(@response.body)
      json['yes'].must_equal 1
      json['total'].must_equal 2
    end
  end

  it 'test cant helpful yourself' do
    login_as @admin
    assert_no_difference 'Helpful.count' do
      create_helpful(true)
      must_respond_with :success
      json = JSON.parse(@response.body)
      json['yes'].must_equal 0
      json['total'].must_equal 0
    end
  end

  it 'test project must exist' do
    login_as create(:account)
    post :create, project_id: 'I_AM_A_BANANA!', review_id: @linux_review.id,
                  format: 'json', helpful: { yes: true }
    must_respond_with :not_found
  end

  it 'test review must exist' do
    login_as create(:account)
    post :create, project_id: projects(:linux).to_param, review_id: 123_456_789,
                  format: 'json', helpful: { yes: true }
    must_respond_with :not_found
  end

  it 'test review must match project' do
    login_as create(:account)
    post :create, project_id: projects(:adium).to_param, review_id: @linux_review.id,
                  format: 'json', helpful: { yes: true }
    must_respond_with :not_found
  end

  private

  def create_helpful(helpful)
    post :create, project_id: projects(:linux).to_param, review_id: @linux_review.id,
                  format: 'json', helpful: { yes: helpful }
  end
end
