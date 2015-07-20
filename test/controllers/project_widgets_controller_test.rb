require 'test_helper'

describe 'ProjectWidgetsController' do
  let(:project) { create(:project, name: "apostro'phic") }
  let(:widget_classes) do
    [ProjectWidget::FactoidsStats, ProjectWidget::Factoids, ProjectWidget::BasicStats,
     ProjectWidget::Languages, ProjectWidget::SearchAllCode, ProjectWidget::Cocomo,
     ProjectWidget::PartnerBadge, ProjectWidget::ThinBadge, ProjectWidget::UsersLogo
    ] + [ProjectWidget::Users] * 6
  end

  describe 'index' do
    it 'should return all project widgets and project' do
      get :index, project_id: project.id

      must_respond_with :ok
      assigns(:widgets).map(&:class).must_equal widget_classes
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :index, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end

    it 'must render successfully when no analysis' do
      Project.any_instance.stubs(:best_analysis).returns(NilAnalysis.new)

      get :index, project_id: project.to_param

      must_respond_with :ok
    end
  end

  describe 'basic_stats' do
    it 'should set project and widget' do
      get :project_basic_stats, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::BasicStats
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :project_basic_stats, project_id: project.id, format: :js

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::BasicStats
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :project_basic_stats, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'factoids_stats' do
    it 'should set project and widget' do
      get :project_factoids_stats, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::FactoidsStats
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :project_factoids_stats, project_id: project.id, format: :js

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::FactoidsStats
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :project_factoids_stats, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'factoids' do
    it 'should set project and widget' do
      get :project_factoids, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::Factoids
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :project_factoids, project_id: project.id, format: :js

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::Factoids
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :project_factoids, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'search_all_code' do
    it 'should set project and widget' do
      get :project_search_all_code, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::SearchAllCode
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :project_search_all_code, project_id: project.id, format: :js

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::SearchAllCode
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :project_search_all_code, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'search_code' do
    it 'should set project and widget' do
      get :project_search_code, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::SearchCode
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :project_search_code, project_id: project.id, format: :js

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::SearchCode
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :project_search_code, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'users' do
    it 'should set project and widget' do
      get :project_users, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::Users
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :project_users, project_id: project.id, format: :js, style: 'blue'

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::Users
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :project_users, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'users_logo' do
    it 'should set project and widget' do
      get :project_users_logo, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::UsersLogo
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :project_users_logo, project_id: project.id, format: :js

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::UsersLogo
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :project_users_logo, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'languages' do
    it 'should set project and widget' do
      get :project_languages, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::Languages
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :project_languages, project_id: project.id, format: :js

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::Languages
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :project_languages, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'cocomo' do
    it 'should set project and widget' do
      get :project_cocomo, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::Cocomo
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :project_cocomo, project_id: project.id, format: :js

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::Cocomo
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :project_cocomo, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'partner_badge' do
    it 'should set project and widget' do
      get :project_partner_badge, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::PartnerBadge
      assigns(:project).must_equal project
    end

    it 'should render image for gif format' do
      get :project_partner_badge, project_id: project.id, format: :gif

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::PartnerBadge
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :project_partner_badge, project_id: project.id, format: :js

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::PartnerBadge
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :project_partner_badge, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'thin_badge' do
    it 'should set project and widget' do
      get :project_thin_badge, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::ThinBadge
      assigns(:project).must_equal project
    end

    it 'should render image for gif format' do
      get :project_thin_badge, project_id: project.id, format: :gif

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::ThinBadge
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :project_thin_badge, project_id: project.id, format: :js, ref: 'Thin'

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::ThinBadge
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :project_thin_badge, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end
end
