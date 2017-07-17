require 'test_helper'

describe 'ProjectWidgetsController' do
  let(:project) { create(:project, name: "apostro'phic") }
  let(:widget_classes) do
    [
      ProjectWidget::FactoidsStats, ProjectWidget::Factoids, ProjectWidget::BasicStats,
      ProjectWidget::Languages, ProjectWidget::Cocomo,
      ProjectWidget::PartnerBadge, ProjectWidget::ThinBadge, ProjectWidget::UsersLogo
    ] + [ProjectWidget::Users] * 6 + [ProjectWidget::LastUpdateBadge, ProjectWidget::RatingBadge,
                                      ProjectWidget::RecentContributorsBadge,
                                      ProjectWidget::LanguageBadge, ProjectWidget::MonthlyStatisticsBadge,
                                      ProjectWidget::YearlyStatisticsBadge, ProjectWidget::SecurityExposureBadge,
                                      ProjectWidget::VulnerabilityExposureBadge]
  end

  describe 'index' do
    it 'should return all project widgets and project' do
      get :index, project_id: project.id

      must_respond_with :ok
      assigns(:widgets).map(&:class).must_equal widget_classes
      assigns(:project).must_equal project
    end

    it 'should render deleted projects page if project was deleted' do
      project = create(:project, deleted: true)
      get :index, project_id: project.id

      must_respond_with :ok
      must_render_template 'projects/deleted'
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
      get :basic_stats, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::BasicStats
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :basic_stats, project_id: project.id, format: :js

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::BasicStats
      assigns(:project).must_equal project
    end

    it 'must not direct browsers to prevent iframing' do
      get :basic_stats, project_id: project.id

      must_respond_with :ok
      response.headers.each do |k, v|
        v.must_equal '' if k.casecmp('x-frame-options').zero? || k.casecmp('x-xss-protection').zero?
      end
    end

    it 'should show not found error' do
      get :basic_stats, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end

    it 'should render xml format' do
      get :basic_stats, project_id: project.id, format: :xml

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::BasicStats
    end
  end

  describe 'factoids_stats' do
    it 'should set project and widget' do
      get :factoids_stats, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::FactoidsStats
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :factoids_stats, project_id: project.id, format: :js

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::FactoidsStats
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :factoids_stats, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'factoids' do
    it 'should set project and widget' do
      get :factoids, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::Factoids
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :factoids, project_id: project.id, format: :js

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::Factoids
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :factoids, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'users' do
    it 'should set project and widget' do
      get :users, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::Users
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :users, project_id: project.id, format: :js, style: 'blue'

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::Users
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :users, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'users_logo' do
    it 'should set project and widget' do
      get :users_logo, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::UsersLogo
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :users_logo, project_id: project.id, format: :js

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::UsersLogo
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :users_logo, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'languages' do
    it 'should set project and widget' do
      get :languages, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::Languages
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :languages, project_id: project.id, format: :js

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::Languages
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :languages, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'cocomo' do
    it 'should set project and widget' do
      get :cocomo, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::Cocomo
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :cocomo, project_id: project.id, format: :js

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::Cocomo
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :cocomo, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'partner_badge' do
    it 'should set project and widget' do
      get :partner_badge, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::PartnerBadge
      assigns(:project).must_equal project
    end

    it 'should render image for gif format' do
      get :partner_badge, project_id: project.id, format: :gif

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::PartnerBadge
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :partner_badge, project_id: project.id, format: :js

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::PartnerBadge
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :partner_badge, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'thin_badge' do
    it 'should set project and widget' do
      get :thin_badge, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::ThinBadge
      assigns(:project).must_equal project
    end

    it 'should render image for gif format' do
      get :thin_badge, project_id: project.id, format: :gif

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::ThinBadge
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :thin_badge, project_id: project.id, format: :js, ref: 'Thin'

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::ThinBadge
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :thin_badge, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'vulnerability_exposure_badge' do
    before do
      create(:project_vulnerability_report, project: project)
    end

    it 'should set project and widget' do
      get :vulnerability_exposure_badge, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::VulnerabilityExposureBadge
      assigns(:project).must_equal project
    end

    it 'should render image for gif format' do
      get :vulnerability_exposure_badge, project_id: project.id, format: :gif

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::VulnerabilityExposureBadge
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :vulnerability_exposure_badge, project_id: project.id, format: :js, ref: 'Thin'

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::VulnerabilityExposureBadge
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :vulnerability_exposure_badge, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'security_exposure_badge' do
    before do
      create(:project_vulnerability_report, project: project)
    end

    it 'should set project and widget' do
      get :security_exposure_badge, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::SecurityExposureBadge
      assigns(:project).must_equal project
    end

    it 'should render image for gif format' do
      get :security_exposure_badge, project_id: project.id, format: :gif

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::SecurityExposureBadge
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :security_exposure_badge, project_id: project.id, format: :js, ref: 'Thin'

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::SecurityExposureBadge
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :security_exposure_badge, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'language_badge' do
    it 'should set project and widget' do
      get :language_badge, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::LanguageBadge
      assigns(:project).must_equal project
    end

    it 'should render image for gif format' do
      create(:activity_fact, analysis: project.best_analysis, code_added: 6,
                             code_removed: 5, comments_added: 5, comments_removed: 4)

      get :language_badge, project_id: project.id, format: :gif

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::LanguageBadge
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :language_badge, project_id: project.id, format: :js, ref: 'Thin'

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::LanguageBadge
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :language_badge, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'last_update_badge' do
    it 'should set project and widget' do
      get :last_update_badge, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::LastUpdateBadge
      assigns(:project).must_equal project
    end

    it 'should render image for gif format' do
      project.best_analysis.update_attribute(:oldest_code_set_time, Time.zone.now)
      get :last_update_badge, project_id: project.id, format: :gif

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::LastUpdateBadge
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :last_update_badge, project_id: project.id, format: :js, ref: 'Thin'

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::LastUpdateBadge
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :last_update_badge, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'rating_badge' do
    it 'should set project and widget' do
      get :rating_badge, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::RatingBadge
      assigns(:project).must_equal project
    end

    it 'should render image for gif format' do
      get :rating_badge, project_id: project.id, format: :gif

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::RatingBadge
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :rating_badge, project_id: project.id, format: :js, ref: 'Thin'

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::RatingBadge
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :rating_badge, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'recent_contributors_badge' do
    it 'should set project and widget' do
      get :recent_contributors_badge, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::RecentContributorsBadge
      assigns(:project).must_equal project
    end

    it 'should render image for gif format' do
      all_time_summary = create(:all_time_summary_summary_with_name_ids, analysis: project.best_analysis)
      create(:person, name_id: all_time_summary.recent_contributors.drop(1).first, project: project)
      get :recent_contributors_badge, project_id: project.id, format: :gif

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::RecentContributorsBadge
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :recent_contributors_badge, project_id: project.id, format: :js, ref: 'Thin'

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::RecentContributorsBadge
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :recent_contributors_badge, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'monthly_statistics_badge' do
    it 'should set project and widget' do
      get :monthly_statistics_badge, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::MonthlyStatisticsBadge
      assigns(:project).must_equal project
    end

    it 'should render image for gif format' do
      get :monthly_statistics_badge, project_id: project.id, format: :gif

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::MonthlyStatisticsBadge
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :monthly_statistics_badge, project_id: project.id, format: :js, ref: 'Thin'

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::MonthlyStatisticsBadge
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :monthly_statistics_badge, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end

  describe 'yearly_statistics_badge' do
    it 'should set project and widget' do
      get :yearly_statistics_badge, project_id: project.id

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::YearlyStatisticsBadge
      assigns(:project).must_equal project
    end

    it 'should render image for gif format' do
      project.best_analysis.twelve_month_summary.update_attributes(affiliated_commits_count: 8)
      get :yearly_statistics_badge, project_id: project.id, format: :gif

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::YearlyStatisticsBadge
      assigns(:project).must_equal project
    end

    it 'should render iframe for js format' do
      get :yearly_statistics_badge, project_id: project.id, format: :js, ref: 'Thin'

      must_respond_with :ok
      assigns(:widget).class.must_equal ProjectWidget::YearlyStatisticsBadge
      assigns(:project).must_equal project
    end

    it 'should show not found error' do
      get :yearly_statistics_badge, project_id: 0

      must_respond_with :ok
      @response.body.must_equal I18n.t('widgets.not_found')
    end
  end
end
