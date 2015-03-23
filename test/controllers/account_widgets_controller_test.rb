require 'test_helper'

describe 'AccountWidgetsController' do
  let(:account) { create(:account) }

  describe 'index' do
    it 'should return all account widgets and account' do
      get :index, account_id: account.id

      must_respond_with :ok
      widget_classes = [AccountWidget::Detailed, AccountWidget::Rank, AccountWidget::Tiny]
      assigns(:widgets).map(&:class).must_equal widget_classes
      assigns(:account).must_equal account
    end
  end

  describe 'detailed' do
    it 'should set account and widget' do
      get :detailed, account_id: account.id

      must_respond_with :ok
      assigns(:widget).class.must_equal AccountWidget::Detailed
      assigns(:account).must_equal account
    end

    it 'should show not found error' do
      get :detailed, account_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end

    it 'should render image for gif format' do
      skip('TODO: implement after mini_magick')
      get :detailed, account_id: account.id, format: :gif

      must_respond_with :ok
      assigns(:widgets).map(&:class).must_equal AccountWidget::Detailed
      assigns(:account).must_equal account
    end
  end

  describe 'rank' do
    it 'should set account and widget' do
      get :rank, account_id: account.id

      must_respond_with :ok
      assigns(:widget).class.must_equal AccountWidget::Rank
      assigns(:account).must_equal account
    end

    it 'should show not found error' do
      get :rank, account_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end

    it 'should render image for gif format' do
      skip('TODO: implement after mini_magick')
      get :rank, account_id: account.id, format: :gif

      must_respond_with :ok
      assigns(:widgets).map(&:class).must_equal AccountWidget::Rank
      assigns(:account).must_equal account
    end
  end

  describe 'tiny' do
    it 'should set account and widget' do
      get :tiny, account_id: account.id

      must_respond_with :ok
      assigns(:widget).class.must_equal AccountWidget::Tiny
      assigns(:account).must_equal account
    end

    it 'should show not found error' do
      get :tiny, account_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end

    it 'should render image for gif format' do
      skip('TODO: implement after mini_magick')
      get :tiny, account_id: account.id, format: :gif

      must_respond_with :ok
      assigns(:widgets).map(&:class).must_equal AccountWidget::Tiny
      assigns(:account).must_equal account
    end
  end
end
