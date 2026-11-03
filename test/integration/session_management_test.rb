# frozen_string_literal: true

require 'test_helper'

class SessionManagementTest < ActionDispatch::IntegrationTest
  it 'logging in redirects back to the page you were last on' do
    project = create(:project)
    login_as nil
    get project_path(project)
    password = PasswordGenerator.generate
    user = create(:account, password: password, email_opportunities_visited: 5.days.ago)
    post sessions_path, params: { login: { login: user.login, password: password } }
    assert_redirected_to project_path(project)
  end
end
