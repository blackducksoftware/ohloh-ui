require 'test_helper'

describe 'Admin::CodeLocationsController' do
  let(:admin) { create(:admin) }
  let(:project) { create(:project) }
  let(:code_location) { create(:code_location) }
  before do
    login_as admin
  end

  describe '#index' do
    it 'should render index template' do
      get :index
      must_respond_with :ok
      must_render_template :index
    end
  end

  describe '#show' do
    it 'should render show page when code location is passd' do
      get :show, id: code_location
      must_respond_with :ok
      must_render_template :show
    end
  end
end
