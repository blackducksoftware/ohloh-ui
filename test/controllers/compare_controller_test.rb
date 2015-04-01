require 'test_helper'

class CompareControllerTest < ActionController::TestCase
  # projects
  test 'should render with no projects passed in' do
    get :projects
    assert_response :success
    assert_select 'input#project_0', 1
    assert_select 'input#project_1', 1
    assert_select 'input#project_2', 1
  end

  test 'should render up to three projects' do
    project1 = create(:project, name: 'Phil')
    project2 = create(:project, name: 'Jerry')
    project3 = create(:project, name: 'Bob')
    get :projects, project_0: project1.name, project_1: project2.name, project_2: project3.name
    assert_response :success
    assert_select 'input#project_0', 0
    assert_select 'input#project_1', 0
    assert_select 'input#project_2', 0
    response.body.must_match 'Phil'
    response.body.must_match 'Jerry'
    response.body.must_match 'Bob'
  end

  test 'should handle some nil projects' do
    project1 = create(:project, name: 'Phil')
    project3 = create(:project, name: 'Bob')
    get :projects, project_0: project1.name, project_2: project3.name
    assert_response :success
    assert_select 'input#project_0', 0
    assert_select 'input#project_1', 1
    assert_select 'input#project_2', 0
    response.body.must_match 'Phil'
    response.body.must_match 'Bob'
  end
end
