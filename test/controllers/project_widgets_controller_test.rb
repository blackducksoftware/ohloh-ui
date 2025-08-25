# frozen_string_literal: true

require 'test_helper'

class ProjectWidgetsControllerTest < ActionController::TestCase
  let(:project) { create(:project, name: "apostro'phic") }
  let(:widget_classes) do
    [
      Widget::ProjectWidget::FactoidsStats, Widget::ProjectWidget::Factoids, Widget::ProjectWidget::BasicStats,
      Widget::ProjectWidget::Languages, Widget::ProjectWidget::Cocomo,
      Widget::ProjectWidget::PartnerBadge, Widget::ProjectWidget::ThinBadge, Widget::ProjectWidget::UsersLogo
    ] + ([Widget::ProjectWidget::Users] * 6)
  end

  describe 'index' do
    it 'should return all project widgets and project' do
      get :index, params: { project_id: project.id }

      assert_response :ok
      _(assigns(:project)).must_equal project
    end

    it 'should render deleted projects page if project was deleted' do
      project = create(:project, deleted: true)
      get :index, params: { project_id: project.id }

      assert_response :ok
      assert_template 'projects/deleted'
    end

    it 'should show not found error' do
      get :index, params: { project_id: 0 }

      assert_response :ok
      _(@response.body).must_equal I18n.t('widgets.not_found')
    end

    it 'must render successfully when no analysis' do
      Project.any_instance.stubs(:best_analysis).returns(NilAnalysis.new)

      get :index, params: { project_id: project.to_param }

      assert_response :ok
    end
  end

  describe 'basic_stats' do
    it 'should set project and widget' do
      get :basic_stats, params: { project_id: project.id }

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::BasicStats
      _(assigns(:project)).must_equal project
    end

    it 'should render iframe for js format' do
      get :basic_stats, params: { project_id: project.id }, format: :js

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::BasicStats
      _(assigns(:project)).must_equal project
    end

    it 'must not direct browsers to prevent iframing' do
      get :basic_stats, params: { project_id: project.id }

      assert_response :ok
      response.headers.each do |k, v|
        _(v).must_equal '' if k.casecmp('x-frame-options').zero? || k.casecmp('x-xss-protection').zero?
      end
    end

    it 'should show not found error' do
      get :basic_stats, params: { project_id: 0 }

      assert_response :ok
      _(@response.body).must_equal I18n.t('widgets.not_found')
    end

    it 'should render xml format' do
      get :basic_stats, params: { project_id: project.id }, format: :xml

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::BasicStats
    end
  end

  describe 'factoids_stats' do
    it 'should set project and widget' do
      get :factoids_stats, params: { project_id: project.id }

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::FactoidsStats
      _(assigns(:project)).must_equal project
    end

    it 'should render iframe for js format' do
      get :factoids_stats, params: { project_id: project.id }, format: :js

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::FactoidsStats
      _(assigns(:project)).must_equal project
    end

    it 'should show not found error' do
      get :factoids_stats, params: { project_id: 0 }

      assert_response :ok
      _(@response.body).must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'factoids' do
    it 'should set project and widget' do
      get :factoids, params: { project_id: project.id }

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::Factoids
      _(assigns(:project)).must_equal project
    end

    it 'should render iframe for js format' do
      get :factoids, params: { project_id: project.id }, format: :js

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::Factoids
      _(assigns(:project)).must_equal project
    end

    it 'should show not found error' do
      get :factoids, params: { project_id: 0 }

      assert_response :ok
      _(@response.body).must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'users' do
    it 'should set project and widget' do
      get :users, params: { project_id: project.id }

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::Users
      _(assigns(:project)).must_equal project
    end

    it 'should render iframe for js format' do
      get :users, params: { project_id: project.id, format: :js, style: 'blue' }

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::Users
      _(assigns(:project)).must_equal project
    end

    it 'should show not found error' do
      get :users, params: { project_id: 0 }

      assert_response :ok
      _(@response.body).must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'users_logo' do
    it 'should set project and widget' do
      get :users_logo, params: { project_id: project.id }

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::UsersLogo
      _(assigns(:project)).must_equal project
    end

    it 'should render iframe for js format' do
      get :users_logo, params: { project_id: project.id }, format: :js

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::UsersLogo
      _(assigns(:project)).must_equal project
    end

    it 'should show not found error' do
      get :users_logo, params: { project_id: 0 }

      assert_response :ok
      _(@response.body).must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'languages' do
    it 'should set project and widget' do
      get :languages, params: { project_id: project.id }

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::Languages
      _(assigns(:project)).must_equal project
    end

    it 'should render iframe for js format' do
      get :languages, params: { project_id: project.id }, format: :js

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::Languages
      _(assigns(:project)).must_equal project
    end

    it 'should show not found error' do
      get :languages, params: { project_id: 0 }

      assert_response :ok
      _(@response.body).must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'cocomo' do
    it 'should set project and widget' do
      get :cocomo, params: { project_id: project.id }

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::Cocomo
      _(assigns(:project)).must_equal project
    end

    it 'should render iframe for js format' do
      get :cocomo, params: { project_id: project.id }, format: :js

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::Cocomo
      _(assigns(:project)).must_equal project
    end

    it 'should show not found error' do
      get :cocomo, params: { project_id: 0 }

      assert_response :ok
      _(@response.body).must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'partner_badge' do
    it 'should set project and widget' do
      get :partner_badge, params: { project_id: project.id }

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::PartnerBadge
      _(assigns(:project)).must_equal project
    end

    it 'should render image for gif format' do
      get :partner_badge, params: { project_id: project.id }, format: :gif

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::PartnerBadge
      _(assigns(:project)).must_equal project
    end

    it 'should render iframe for js format' do
      get :partner_badge, params: { project_id: project.id }, format: :js

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::PartnerBadge
      _(assigns(:project)).must_equal project
    end

    it 'should show not found error' do
      get :partner_badge, params: { project_id: 0 }

      assert_response :ok
      _(@response.body).must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'thin_badge' do
    it 'should set project and widget' do
      get :thin_badge, params: { project_id: project.id }

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::ThinBadge
      _(assigns(:project)).must_equal project
    end

    it 'should render image for gif format' do
      get :thin_badge, params: { project_id: project.id }, format: :gif

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::ThinBadge
      _(assigns(:project)).must_equal project
    end

    it 'should render iframe for js format' do
      get :thin_badge, params: { project_id: project.id, ref: 'Thin' }, format: :js

      assert_response :ok
      _(assigns(:widget).class).must_equal Widget::ProjectWidget::ThinBadge
      _(assigns(:project)).must_equal project
    end

    it 'should show not found error' do
      get :thin_badge, params: { project_id: 0 }

      assert_response :ok
      _(@response.body).must_equal I18n.t('widgets.not_found')
    end
  end
end
