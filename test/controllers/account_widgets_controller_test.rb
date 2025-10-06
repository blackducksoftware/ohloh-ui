# frozen_string_literal: true

require 'test_helper'

class AccountWidgetsControllerTest < ActionController::TestCase
  let(:account) { create(:account) }
  before { Rails.application.eager_load! }

  describe 'index' do
    it 'should return all account widgets and account' do
      get :index, params: { account_id: account.id }

      assert_response :ok
      widget_classes = [Widget::AccountWidget::Detailed, Widget::AccountWidget::Rank, Widget::AccountWidget::Tiny]
      _(assigns(:widgets).map(&:class)).must_equal widget_classes
      _(assigns(:account)).must_equal account
    end
  end

  describe 'detailed' do
    it 'should set account and widget' do
      get :detailed, params: { account_id: account.id }

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::AccountWidget::Detailed
      _(assigns(:account)).must_equal account
    end

    it 'should show not found error' do
      get :detailed, params: { account_id: 0 }

      assert_response :ok
      _(@response.body).must_equal I18n.t('widgets.not_found')
    end

    it 'should render image for gif format' do
      account = create(:account, name: "apostro'phic")
      get :detailed, params: { account_id: account.id }, format: :gif

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::AccountWidget::Detailed
      _(assigns(:account)).must_equal account
    end
  end

  describe 'rank' do
    it 'should set account and widget' do
      get :rank, params: { account_id: account.id }

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::AccountWidget::Rank
      _(assigns(:account)).must_equal account
    end

    it 'should show not found error' do
      get :rank, params: { account_id: 0 }

      assert_response :ok
      _(@response.body).must_equal I18n.t('widgets.not_found')
    end

    it 'should render image for gif format' do
      get :rank, params: { account_id: account.id }, format: :gif

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::AccountWidget::Rank
      _(assigns(:account)).must_equal account
    end
  end

  describe 'tiny' do
    it 'should set account and widget' do
      get :tiny, params: { account_id: account.id }

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::AccountWidget::Tiny
      _(assigns(:account)).must_equal account
    end

    it 'should show not found error' do
      get :tiny, params: { account_id: 0 }

      assert_response :ok
      _(@response.body).must_equal I18n.t('widgets.not_found')
    end

    it 'should render image for gif format' do
      get :tiny, params: { account_id: account.id }, format: :gif

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::AccountWidget::Tiny
      _(assigns(:account)).must_equal account
    end
  end
end
