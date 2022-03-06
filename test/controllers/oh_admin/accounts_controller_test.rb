# frozen_string_literal: true

require 'test_helper'

class OhAdmin::AccountsControllerTest < ActionController::TestCase
  let(:admin) { create(:admin) }
  before do
    login_as admin
  end

  describe '#charts' do
    it 'should render index template' do
      [3, 6, 12].each do |period|
        get :charts, params: { period: period }
        assert_response :ok
      end
    end
  end
end
