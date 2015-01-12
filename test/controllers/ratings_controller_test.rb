require 'test_helper'

class RatingsControllerTest < ActionController::TestCase
  def setup
    @account = create(:account)
    @project = create(:project)
  end

  it 'not allow rating a project by unlogged users' do
    login_as nil
    put :rate, id: @project.to_param, score: '5'
    must_respond_with :unauthorized
  end

  it 'allows rating a project with logged in users' do
    login_as @account
    put :rate, id: @project.to_param, score: '5'
    must_respond_with :ok
  end

  it 'not allow rating a project to silly values' do
    login_as @account
    put :rate, id: @project.to_param, score: 'silly'
    must_respond_with :unprocessable_entity
  end

  it 'gracefully handles non-existant projects' do
    login_as @account
    put :rate, id: 'I_am_a_banana', score: '5'
    must_respond_with :not_found
  end

  it 'allows changing a rating on a project' do
    rating = create(:rating, account: @account, project: @project, score: '3')
    login_as @account
    put :rate, id: @project.to_param, score: '5'
    must_respond_with :ok
    @project.reload
    @project.ratings.map(&:id).must_equal [rating.id]
    @project.ratings.map(&:score).must_equal [5]
    @project.rating_average.must_equal 5.0
  end
end
