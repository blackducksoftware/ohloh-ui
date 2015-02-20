require 'test_helper'

describe 'AccountsControllerTest' do
  let(:start_date) do
    (Date.today - 6.years).beginning_of_month
  end

  def start_date_str(month = 0)
    (Time.now - 6.years + month.months).beginning_of_month.strftime('%Y-%m-01 00:00:00')
  end

  let(:user) do
    account = accounts(:user)
    account.best_vita.vita_fact.destroy
    create(:vita_fact, vita_id: account.best_vita_id)
    account
  end

  let(:admin) { accounts(:admin) }

  describe 'index' do
    it 'should return claimed persons with their cbp_map and positions_map' do
      user.best_vita.vita_fact.reload.commits_by_project
      get :index

      must_respond_with :ok
      assigns(:positions_map).length.must_equal 2
      assigns(:people).length.must_equal 9
      assigns(:cbp_map).length.must_equal 9
    end
  end

  describe 'show' do
    it 'should set the account and logos' do
      get :show, id: admin.login

      must_respond_with :ok
      assigns(:account).must_equal admin
      assigns(:logos).must_be_empty
    end

    it 'should redirect if account is disabled' do
      Account::Access.any_instance.stubs(:disabled?).returns(true)

      get :show, id: admin.login
      must_redirect_to disabled_account_url(admin)
    end
  end

  describe 'commits_by_project_chart' do
    it 'should return json chart data' do
      get :commits_by_project_chart, id: user.id
      result  = JSON.parse(response.body)

      must_respond_with :ok
      result['noCommits'].must_equal false
      result['series'].first['data'].must_equal [nil] * 12 + [25, 40, 28, 18, 1, 8, 26, 9] + [nil] * 65
      result['series'].first['name'].must_equal 'Linux'
    end

    it 'should redirect if account is disabled' do
      Account::Access.any_instance.stubs(:disabled?).returns(true)

      get :commits_by_project_chart, id: admin.login
      must_redirect_to disabled_account_url(admin)
    end
  end

  describe 'commits_by_language_chart' do
    it 'should return json chart data when scope is regular' do
      get :commits_by_language_chart, id: user.id, scope: 'regular'
      result = JSON.parse(response.body)

      first_lanugage = result['object_array'].first['table']
      must_respond_with :ok
      first_lanugage['language_id'].must_equal '17'
      first_lanugage['name'].must_equal 'csharp'
      first_lanugage['color_code'].must_equal '4096EE'
      first_lanugage['nice_name'].must_equal 'C#'
      first_lanugage['commits'].must_equal [0] * 12 + [24, 37, 27, 16, 1, 8, 26, 9] + [0] * 64
      first_lanugage['category'].must_equal '0'
    end

    it 'should redirect if account is disabled' do
      Account::Access.any_instance.stubs(:disabled?).returns(true)

      get :commits_by_language_chart, id: admin.login
      must_redirect_to disabled_account_url(admin)
    end
  end

  describe 'languages' do
    it 'should respond with contributions data when best vita for account is nil' do
      contribution = admin.positions.first.contribution
      project = contribution.project

      get :languages, id: admin.id

      must_respond_with :ok
      assigns(:contributions)[project.id].must_equal [contribution]
      assigns(:vlfs).must_equal nil
      assigns(:logos_map).must_equal nil
    end

    it 'should respond with contributions and vita language facts data when best vita for account is present' do
      vita_language_fact = create(:vita_language_fact, vita: user.best_vita)
      most_commits_project = vita_language_fact.most_commits_project
      recent_commit_project = vita_language_fact.recent_commit_project

      contribution = user.positions.first.contribution
      project = contribution.project

      logos_map = { most_commits_project.logo_id => most_commits_project.logo,
                    recent_commit_project.logo_id => recent_commit_project.logo }

      get :languages, id: user.id

      must_respond_with :ok
      assigns(:contributions)[project.id].must_equal [contribution]
      assigns(:vlfs).must_equal [vita_language_fact]
      assigns(:logos_map).must_equal logos_map
    end
  end

  describe 'destroy_feedback' do
    it 'should not update deleted_account if reason is not given' do
      deleted_user = create(:deleted_account, login: user.login, email: user.email,
                                              reasons: nil, reason_other: nil)
      post :destroy_feedback, login: deleted_user.login

      must_respond_with :ok
      assigns(:deleted_account).reasons.must_equal nil
      assigns(:deleted_account).reason_other.must_equal nil
    end

    it 'should render view if request is a get request' do
      deleted_user = create(:deleted_account, login: user.login, email: user.email,
                                              reasons: nil, reason_other: nil)
      get :destroy_feedback

      must_respond_with :ok
      assigns(:deleted_account).must_equal nil
      assigns(:deleted_account).must_equal nil
    end

    it 'should update deleted_account with the reason given' do
      deleted_user = create(:deleted_account, login: user.login, email: user.email,
                                              reasons: nil, reason_other: nil)
      post :destroy_feedback, login: deleted_user.login, reasons: [1, 2, 3], reason_other: 'reason'

      must_redirect_to message_path
      assigns(:deleted_account).reasons.must_equal [1, 2, 3]
      assigns(:deleted_account).reason_other.must_equal 'reason'
      flash[:success].must_equal I18n.t('accounts.destroy_feedback.success')
    end
  end
end
