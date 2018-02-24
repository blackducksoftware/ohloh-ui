require 'test_helper'

describe 'OhAdmin::DashboardController' do
  let(:admin) { create(:admin) }

  it 'should render dashboard for a logged admin user' do
    login_as admin
    get :index
    must_respond_with :ok
    must_render_template :index
  end

  it 'should unauthorized for non admins' do
    get :index
    must_respond_with :unauthorized
  end
end
