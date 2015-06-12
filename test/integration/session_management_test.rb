require 'test_helper'

class SessionManagementTest < ActionDispatch::IntegrationTest
  it 'logging in redirects back to the page you were last on' do
    project = create(:project)
    login_as nil
    get project_path(project)
    user = create(:account, password: 'xyzzy123456', email_opportunities_visited: 5.days.ago)
    user.password = 'xyzzy123456'
    post sessions_path, login: { login: user.email, password: 'xyzzy123456' }
    assert_redirected_to project_path(project)
  end
end
