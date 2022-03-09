# frozen_string_literal: true

require 'test_helper'

class StackWidgetsControllerTest < ActionController::TestCase
  let(:stack) { create(:stack) }

  describe 'index' do
    it 'should return stack widgets and stack and its account' do
      get :index, params: { stack_id: stack.id }

      assert_response :ok
      _(assigns(:widget).class).must_equal StackWidget
      _(assigns(:stack)).must_equal stack
      _(assigns(:account)).must_equal stack.account
    end
  end

  describe 'normal' do
    it 'should set stack and widget' do
      get :normal, params: { stack_id: stack.id }

      assert_response :ok
      _(assigns(:widget).class).must_equal StackWidget
      _(assigns(:stack)).must_equal stack
    end

    it 'should show not found error' do
      get :normal, params: { stack_id: 0 }

      assert_response :ok
      _(@response.body).must_equal I18n.t('widgets.not_found')
    end
  end
end
