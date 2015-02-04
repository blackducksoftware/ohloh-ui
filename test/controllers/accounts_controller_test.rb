require 'test_helper'

describe 'AccountsControllerTest' do
  let(:start_date) do
    (Date.today - 6.years).beginning_of_month
  end

  def start_date_str(month = 0)
    (Time.now - 6.years + month.months).beginning_of_month.strftime('%Y-%m-01 00:00:00')
  end

  let(:cbl) do
    [{ 'l_id' => '3', 'l_name' => 'xml', 'l_category' => '1', 'l_nice_name' => 'XML',
       'month' => start_date.to_s, 'commits' => '8' },
     { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
       'month' => start_date.to_s, 'commits' => '24' },
     { 'l_id' => '1', 'l_name' => 'html', 'l_category' => '1', 'l_nice_name' => 'HTML',
       'month' => (start_date + 1.month).to_s, 'commits' => '9' },
     { 'l_id' => '3', 'l_name' => 'xml', 'l_category' => '1', 'l_nice_name' => 'XML',
       'month' => (start_date + 1.month).to_s, 'commits' => '29' },
     { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
       'month' => (start_date + 1.month).to_s, 'commits' => '37' },
     { 'l_id' => '3', 'l_name' => 'xml', 'l_category' => '1', 'l_nice_name' => 'XML',
       'month' => (start_date + 2.months).to_s, 'commits' => '7' },
     { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
       'month' => (start_date + 2.months).to_s, 'commits' => '27' },
     { 'l_id' => '30', 'l_name' => 'sql', 'l_category' => '0', 'l_nice_name' => 'SQL',
       'month' => (start_date + 2.months).to_s, 'commits' => '1' },
     { 'l_id' => '3', 'l_name' => 'xml', 'l_category' => '1', 'l_nice_name' => 'XML',
       'month' => (start_date + 3.months).to_s, 'commits' => '2' },
     { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
       'month' => (start_date + 3.months).to_s, 'commits' => '16' },
     { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
       'month' => (start_date + 4.months).to_s, 'commits' => '1' },
     { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
       'month' => (start_date + 5.months).to_s, 'commits' => '8' },
     { 'l_id' => '3', 'l_name' => 'xml', 'l_category' => '1', 'l_nice_name' => 'XML',
       'month' => (start_date + 6.months).to_s, 'commits' => '12' },
     { 'l_id' => '12', 'l_name' => 'ruby', 'l_category' => '0', 'l_nice_name' => 'Ruby',
       'month' => (start_date + 6.months).to_s, 'commits' => '2' },
     { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
       'month' => (start_date + 6.months).to_s, 'commits' => '26' },
     { 'l_id' => '3', 'l_name' => 'xml', 'l_category' => '1', 'l_nice_name' => 'XML',
       'month' => (start_date + 7.months).to_s, 'commits' => '2' },
     { 'l_id' => '12', 'l_name' => 'ruby', 'l_category' => '0', 'l_nice_name' => 'Ruby',
       'month' => (start_date + 7.months).to_s, 'commits' => '3' },
     { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
       'month' => (start_date + 7.months).to_s, 'commits' => '9' }]
  end

  let(:cbp) do
    [{ 'month' => start_date_str, 'commits' => '25', 'position_id' => '1' },
     { 'month' => start_date_str(1), 'commits' => '40', 'position_id' => '1' },
     { 'month' => start_date_str(2), 'commits' => '28', 'position_id' => '1' },
     { 'month' => start_date_str(3), 'commits' => '18', 'position_id' => '1' },
     { 'month' => start_date_str(4), 'commits' => '1', 'position_id' => '1' },
     { 'month' => start_date_str(5), 'commits' => '8', 'position_id' => '1' },
     { 'month' => start_date_str(6), 'commits' => '26', 'position_id' => '1' },
     { 'month' => start_date_str(6), 'commits' => '4', 'position_id' => '2' },
     { 'month' => start_date_str(7), 'commits' => '9', 'position_id' => '1' },
     { 'month' => start_date_str(7), 'commits' => '3', 'position_id' => '2' }]
  end

  let(:user) do
    account = accounts(:user)
    account.best_vita.vita_fact.update(commits_by_project: cbp)
    account.best_vita.vita_fact.update(commits_by_language: cbl)
    account
  end

  let(:admin) { accounts(:admin) }

  describe 'index' do
    it 'should return claimed persons with their cbp_map and positions_map' do
      user.best_vita.vita_fact.update(commits_by_project: cbp)

      get :index

      must_respond_with :ok
      assigns(:people).length.must_equal 7
      assigns(:cbp_map).length.must_equal 7
      assigns(:positions_map).length.must_equal 2
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
