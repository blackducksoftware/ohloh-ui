# frozen_string_literal: true

require 'test_helper'

class OrganizationWidgetsControllerTest < ActionController::TestCase
  let(:org) { create(:organization) }

  describe 'index' do
    it 'should return all org widgets and org' do
      get :index, params: { organization_id: org.id }

      assert_response :ok
      widget_classes = [OrganizationWidget::OpenSourceActivity,
                        OrganizationWidget::PortfolioProjectsActivity,
                        OrganizationWidget::AffiliatedCommittersActivity]
      _(assigns(:widgets).map(&:class)).must_equal widget_classes
      _(assigns(:organization)).must_equal org
    end

    it 'should inform client that gifs are not supported' do
      get :index, params: { organization_id: org.id }, format: :gif
      assert_response :not_acceptable
    end
  end

  describe 'open_source_activity' do
    it 'should set org and widget' do
      get :open_source_activity, params: { organization_id: org.id }

      assert_response :ok
      _(assigns(:widget).class).must_equal OrganizationWidget::OpenSourceActivity
      _(assigns(:organization)).must_equal org
    end

    it 'should render iframe for js request' do
      get :open_source_activity, params: { organization_id: org.id }, format: :js

      assert_template :iframe
      _(assigns(:widget).class).must_equal OrganizationWidget::OpenSourceActivity
      _(assigns(:organization)).must_equal org
    end

    it 'should show not found error' do
      get :open_source_activity, params: { organization_id: 0 }

      assert_response :ok
      _(@response.body).must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'affiliated_committers_activity' do
    it 'should set org and widget' do
      get :affiliated_committers_activity, params: { organization_id: org.id }

      assert_response :ok
      _(assigns(:widget).class).must_equal OrganizationWidget::AffiliatedCommittersActivity
      _(assigns(:organization)).must_equal org
    end

    it 'should render iframe for js format' do
      get :affiliated_committers_activity, params: { organization_id: org.id }, format: :js

      assert_template :iframe
      _(assigns(:widget).class).must_equal OrganizationWidget::AffiliatedCommittersActivity
      _(assigns(:organization)).must_equal org
    end

    it 'should show not found error' do
      get :affiliated_committers_activity, params: { organization_id: 0 }

      assert_response :ok
      _(@response.body).must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'portfolio_projects_activity' do
    it 'should set org and widget' do
      get :portfolio_projects_activity, params: { organization_id: org.id }

      assert_response :ok
      _(assigns(:widget).class).must_equal OrganizationWidget::PortfolioProjectsActivity
      _(assigns(:organization)).must_equal org
    end

    it 'should render iframe for js format' do
      get :portfolio_projects_activity, params: { organization_id: org.id }, format: :js

      assert_template :iframe
      _(assigns(:widget).class).must_equal OrganizationWidget::PortfolioProjectsActivity
      _(assigns(:organization)).must_equal org
    end

    it 'should show not found error' do
      get :portfolio_projects_activity, params: { organization_id: 0 }

      assert_response :ok
      _(@response.body).must_equal I18n.t('widgets.not_found')
    end
  end
end
