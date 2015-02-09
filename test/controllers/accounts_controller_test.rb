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
    create(:vita_fact_with_cbl_and_cbp, vita_id: account.best_vita_id)
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
end
