# frozen_string_literal: true

require 'test_helper'

class Api::V1::KnowledgeBaseStatusControllerTest < ActionController::TestCase
  include JWTHelper

  let(:rmq_mock) { mock_bunny }
  before do
    @account = create(:admin)
    ENV['JWT_SECRET_API_KEY'] = Faker::Alphanumeric.alpha(number: 5)
    @jwt = build_jwt(@account.login, 24)
    @project = create(:project)
  end

  describe 'sync' do
    it 'give success status' do
      rmq_mock
      post :sync, params: { JWT: @jwt, project_id: @project.id }
      _(response).must_be :successful?
    end

    it 'give bad request' do
      post :sync, params: { JWT: @jwt, project_id: @project.id }
      _(response).wont_be :successful?
    end
  end
end
