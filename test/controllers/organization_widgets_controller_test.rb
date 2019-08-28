# frozen_string_literal: true

require 'test_helper'

describe 'OrganizationWidgetsController' do
  let(:org) { create(:organization) }

  describe 'index' do
    it 'should return all org widgets and org' do
      get :index, organization_id: org.id

      must_respond_with :ok
      widget_classes = [OrganizationWidget::OpenSourceActivity,
                        OrganizationWidget::PortfolioProjectsActivity,
                        OrganizationWidget::AffiliatedCommittersActivity]
      assigns(:widgets).map(&:class).must_equal widget_classes
      assigns(:organization).must_equal org
    end

    it 'should inform client that gifs are not supported' do
      get :index, organization_id: org.id, format: :gif
      must_respond_with :not_acceptable
    end
  end

  describe 'open_source_activity' do
    it 'should set org and widget' do
      get :open_source_activity, organization_id: org.id

      must_respond_with :ok
      assigns(:widget).class.must_equal OrganizationWidget::OpenSourceActivity
      assigns(:organization).must_equal org
    end

    it 'should render iframe for js request' do
      get :open_source_activity, organization_id: org.id, format: :js

      must_render_template :iframe
      assigns(:widget).class.must_equal OrganizationWidget::OpenSourceActivity
      assigns(:organization).must_equal org
    end

    it 'should show not found error' do
      get :open_source_activity, organization_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'affiliated_committers_activity' do
    it 'should set org and widget' do
      get :affiliated_committers_activity, organization_id: org.id

      must_respond_with :ok
      assigns(:widget).class.must_equal OrganizationWidget::AffiliatedCommittersActivity
      assigns(:organization).must_equal org
    end

    it 'should render iframe for js format' do
      get :affiliated_committers_activity, organization_id: org.id, format: :js

      must_render_template :iframe
      assigns(:widget).class.must_equal OrganizationWidget::AffiliatedCommittersActivity
      assigns(:organization).must_equal org
    end

    it 'should show not found error' do
      get :affiliated_committers_activity, organization_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'portfolio_projects_activity' do
    it 'should set org and widget' do
      get :portfolio_projects_activity, organization_id: org.id

      must_respond_with :ok
      assigns(:widget).class.must_equal OrganizationWidget::PortfolioProjectsActivity
      assigns(:organization).must_equal org
    end

    it 'should render iframe for js format' do
      get :portfolio_projects_activity, organization_id: org.id, format: :js

      must_render_template :iframe
      assigns(:widget).class.must_equal OrganizationWidget::PortfolioProjectsActivity
      assigns(:organization).must_equal org
    end

    it 'should show not found error' do
      get :portfolio_projects_activity, organization_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end
end
