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

    it 'should render index template with filter' do
      %w[weekly monthly].each do |data|
        get :charts, params: { filter_by: data }
        assert_response :ok
      end
    end

    it 'should render index template with filter and period' do
      [3, 6, 12].each do |period|
        %w[weekly monthly].each do |data|
          get :charts, params: { period: period, filter_by: data }
          assert_response :ok
        end
      end
    end

    it 'should render index template without filter and period' do
      get :charts, params: { period: '', filter_by: '' }
      assert_response :ok
    end
  end
end
