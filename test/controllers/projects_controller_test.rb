require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  # autocomplete action
  it 'create should require a current user' do
    project1 = create(:project, name: 'Foo')
    project2 = create(:project, name: 'Foobar')
    create(:project, name: 'Goobaz')
    get :autocomplete, term: 'foo', format: :json
    must_respond_with :ok
    resp = JSON.parse(response.body)
    resp.length.must_equal 2
    resp[0]['id'].must_equal project1.to_param
    resp[0]['value'].must_equal project1.name
    resp[1]['id'].must_equal project2.to_param
    resp[1]['value'].must_equal project2.name
  end
end
