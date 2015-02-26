require 'test_helper'

describe 'AccountsController' do
  let(:user) { accounts(:user) }
  let(:start_date) do
    (Date.today - 6.years).beginning_of_month
  end

  let(:cbp) do
    [{ month: Time.parse('2010-04-30 20:00:00 -0400'), commits: 1, position_id: 3 },
     { month: Time.parse('2010-04-30 20:00:00 -0400'), commits: 6, position_id: 1 },
     { month: Time.parse('2011-01-01 00:00:00'), commits: 1, position_id: 3 },
     { month: Time.parse('2012-11-01 00:00:00'), commits: 1, position_id: 1 }]
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

    it 'should redirect if account is labeled a spammer' do
      account = create(:account)
      account_access = Account::Access.new(account)
      account_access.spam!
      account_access.spam?.must_equal true
      account.level.must_equal Account::Access::SPAM
      get :show, id: account.id
      must_redirect_to disabled_account_url(account)
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

  describe 'make spammer' do
    it 'admin should be able to label a spammer' do
      login_as admin
      post :make_spammer, id: user.id
      must_render_template 'accounts/disabled'
      flash[:success].must_equal I18n.t('accounts.make_spammer.success', name: user.name)
    end

    it 'user should not be able to label a spammer' do
      user2 = create(:account)
      login_as user
      post :make_spammer, id: user2.id
      must_respond_with :unauthorized
    end

    it 'should mark an account as spammer' do
      login_as admin
      admin.level.must_equal Account::Access::ADMIN
      get :make_spammer, id: admin.id

      must_render_template 'accounts/disabled'
      admin.reload.level.must_equal Account::Access::SPAM
      flash[:success].must_equal I18n.t('accounts.make_spammer.success', name: admin.name)
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
      user.delete
      post :destroy_feedback, login: deleted_user.login

      must_respond_with :ok
      assigns(:deleted_account).reasons.must_equal nil
      assigns(:deleted_account).reason_other.must_equal nil
    end

    it 'should render view if request is a get request' do
      create(:deleted_account, login: user.login, email: user.email, reasons: nil, reason_other: nil)
      user.delete
      get :destroy_feedback, login: user.login

      must_respond_with :ok
      assigns(:deleted_account).reasons.must_equal nil
    end

    it 'should update deleted_account with the reason given' do
      deleted_user = create(:deleted_account, login: user.login, email: user.email,
                                              reasons: nil, reason_other: nil)
      user.delete
      post :destroy_feedback, login: deleted_user.login, reasons: [1, 2, 3], reason_other: 'reason'

      must_redirect_to message_path
      assigns(:deleted_account).reasons.must_equal [1, 2, 3]
      assigns(:deleted_account).reason_other.must_equal 'reason'
      flash[:success].must_equal I18n.t('accounts.destroy_feedback.success')
    end

    it 'should redirect to message path when feedback time elapsed' do
      user.delete
      post :destroy_feedback, login: user.login, reasons: [1, 2, 3], reason_other: 'reason'

      must_redirect_to message_path
      assigns(:deleted_account).must_equal nil
      flash[:error].must_equal I18n.t('accounts.destroy_feedback.invalid_request')
    end

    it 'should redirect to message path when feedback time elapsed' do
      create(:deleted_account, login: user.login, email: user.email, reasons: nil, reason_other: nil)
      user.delete
      DeletedAccount.any_instance.stubs(:feedback_time_elapsed?).returns(true)
      post :destroy_feedback, login: user.login, reasons: [1, 2, 3], reason_other: 'reason'

      must_redirect_to message_path
      flash[:error].must_equal I18n.t('accounts.destroy_feedback.expired')
    end
  end

  describe 'activate' do
    it 'should successfully activate account' do
      account = Account.create(login: 'ralph', password: 'abcdef', password_confirmation: 'abcdef',
                               email: 'ralph@mailinator.com', email_confirmation: 'ralph@mailinator.com')

      get :activate, id: account.to_param, code: account.activation_code

      must_redirect_to account_path(account)
      flash[:success].must_equal I18n.t('accounts.activate.success')
      session[:account].must_equal account.id
    end

    it 'should redirect to maintainance page in diabled mode' do
      ApplicationController.any_instance.stubs(:read_only_mode?).returns(true)
      account = Account.create(login: 'ralph', password: 'abcdef', password_confirmation: 'abcdef',
                               email: 'ralph@mailinator.com', email_confirmation: 'ralph@mailinator.com')
      get :activate, id: account.to_param, code: account.activation_code

      must_redirect_to maintenance_path
    end

    it 'should redirect already activated message' do
      account = Account.create(login: 'ralph', password: 'abcdef', password_confirmation: 'abcdef',
                               email: 'ralph@mailinator.com', email_confirmation: 'ralph@mailinator.com')
      Account::Access.new(account).activate!(account.activation_code)

      get :activate, id: account.to_param, code: account.activation_code

      must_redirect_to account_path(account)
      flash[:notice].must_equal I18n.t('accounts.activate.notice')
    end
  end

  describe 'search' do
    it 'should return formatted account records as json' do
      xhr :get, :search, term: 'luck'

      result = JSON.parse(response.body)
      result.first['id'].must_equal 'user'
      result.first['value'].must_equal 'user'
      result.last['id'].must_equal 'privacy'
      result.last['value'].must_equal 'privacy'
    end

    it 'should redirect ro peoples page when request is not ajax' do
      get :search, term: 'luck'

      must_redirect_to people_path(q: 'luck')
    end
  end

  describe 'resolve_login' do
    it 'should return account attributes when account is present' do
      create(:account, login: 'robin')
      xhr :get, :resolve_login, q: 'robin'
      result = JSON.parse(response.body)

      result['login'].must_equal 'robin'
      result['q'].must_equal 'robin'
    end

    it 'should return id as nil when account is not present' do
      xhr :get, :resolve_login, q: 'test'
      result = JSON.parse(response.body)

      result['id'].must_equal nil
      result['q'].must_equal 'test'
    end
  end

  describe 'unsubscribe_emails' do
    it 'a valid key for a account should unsubscribe the user' do
      key = Ohloh::Cipher.encrypt(create(:account).id.to_s)
      get :unsubscribe_emails, key: CGI.unescape(key)
      must_respond_with :ok
      assigns(:account).email_master.must_equal false
    end
  end

  describe 'autocomplete' do
    it 'should return account hash' do
      xhr :get, :autocomplete, term: 'luck'

      result = JSON.parse(response.body)
      result.first['login'].must_equal 'user'
      result.first['value'].must_equal 'user'
      result.first['name'].must_equal 'user Luckey'
    end
  end

  describe 'new' do
    it 'must respond with success' do
      get :new
      must_respond_with :success
    end

    it 'must redirect to maintenance during read only mode' do
      ApplicationController.any_instance.stubs(:read_only_mode?).returns(true)
      get :new
      must_redirect_to maintenance_path
    end
  end

  describe 'create' do
    let(:account_attributes) do
      FactoryGirl.attributes_for(:account).select do |k, _v|
        %w(login email email_confirmation password password_confirmation).include?(k.to_s)
      end
    end

    let(:valid_params) do
      valid_honeypot_and_captcha_params = {
        token: :valid_token, honeypot: '',
        recaptcha_challenge_field: :challenge, recaptcha_response_field: :response }

      { account: account_attributes }.merge(valid_honeypot_and_captcha_params)
    end

    before do
      HoneyPotField.create!(field_name: :honeypot, token: :valid_token)
      AccountsController.any_instance.stubs(:verify_recaptcha)
    end

    it 'must render the new template when validations fail' do
      post :create, valid_params.merge(account: { email: '' })
      assigns(:account).wont_be :valid?
      must_render_template :new
    end

    it 'must render the new template for invalid captcha' do
      assert_no_difference 'Account.count' do
        stub_verify_recaptcha_to_add_captcha_error
        post :create, valid_params.merge(recaptcha_response_field: '')

        assigns(:account).errors.messages[:captcha].must_be :present?
        must_render_template :new
      end
    end

    it 'must redirect for valid captcha' do
      assert_difference 'Account.count', 1 do
        post :create, valid_params
        must_respond_with :redirect
      end
    end

    it 'must redirect to home page if honeypot field is filled' do
      post :create, valid_params.merge(honeypot: :filled_by_bot)

      must_redirect_to root_path
    end

    it 'must redirect to home page if token field value is invalid' do
      post :create, valid_params.merge(token: :invalid_token)

      must_redirect_to root_path
    end

    it 'must redirect to home page if token field is expired' do
      HoneyPotField.last.update!(expired: true)
      post :create, valid_params

      must_redirect_to root_path
    end

    it 'must redirect to maintenance during read only mode' do
      ApplicationController.any_instance.stubs(:read_only_mode?).returns(true)
      assert_no_difference 'Account.count' do
        post :create, valid_params
        must_redirect_to maintenance_path
      end
    end

    it 'must require login' do
      assert_no_difference 'Account.count' do
        post :create, valid_params.merge(account: { login: '' })
        assigns(:account).errors.messages[:login].must_be :present?
      end
    end

    it 'must require password' do
      assert_no_difference 'Account.count' do
        post :create, valid_params.merge(account: { password: '' })
        assigns(:account).errors.messages[:password].must_be :present?
      end
    end

    it 'must require email and email_confirmation' do
      assert_no_difference 'Account.count' do
        post :create, valid_params.merge(account: { email_confirmation: '', email: '' })
        assigns(:account).errors.messages[:email_confirmation].must_be :present?
        assigns(:account).errors.messages[:email_confirmation].must_be :present?
      end
    end

    it 'must render the new account page for a blacklisted email domain' do
      bad_domain = 'really_bad_domain.com'
      DomainBlacklist.create(domain: bad_domain)

      assert_no_difference 'Account.count' do
        email = "bad_guy@#{ bad_domain }"
        post :create, valid_params.merge(account: { email: email, email_confirmation: email })

        must_render_template :new
        Account.find_by(email: email).wont_be :present?
      end
    end

    it 'must create an action record when relevant params are passed' do
      person = create(:person)

      assert_difference 'Action.count', 1 do
        post :create, valid_params.merge(_action: "claim_#{ person.id }")
      end

      action = Action.last
      action.status.must_equal 'after_activation'
      action.claim_person_id.must_equal person.id
      action.account_id.must_equal Account.last.id
    end
  end

  describe 'edit' do
    it 'must respond with not_found when account does not exist' do
      get :edit, id: :anything
      must_respond_with :not_found
    end

    it 'must respond with success' do
      account = create(:account)
      login_as account
      get :edit, id: account.to_param
      must_render_template 'edit'
      must_respond_with :success
    end

    it 'must render error if not logged in' do
      get :edit, id: create(:account).id
      must_render_template 'error.html'
    end

    it 'must redirect to new_session if account is not owned' do
      account = create(:account)
      login_as account
      get :edit, id: create(:account).id
      must_redirect_to new_session_path
    end

    it 'must logout spammer trying to edit or update' do
      skip 'FIXME: Integrate alongwith handle_spammer_account'
      account = create(:account)
      login_as account
      Account::Access.new(account).spam!

      get :edit, id: account.to_param
      session[:account_id].must_be_nil
      account.reload.remember_token.must_be_nil
      cookies[:auth_token].must_be_nil
      flash[:notice].wont_be_nil
      must_respond_with :redirect
    end
  end

  describe 'update' do
    let(:account) { create(:account) }
    before { login_as account }

    it 'must fail for invalid data' do
      url = :not_an_url
      post :update, id: account, account: { url: url }
      must_render_template 'edit'
      account.reload.url.wont_equal url
    end

    it 'must display description after a validation error' do
      text = 'about raw content'
      post :update, id: account.to_param, account: { email: '', about_raw: text }

      must_select 'textarea.edit-description', text: text
    end

    it 'must not allow description beyond 500 characters' do
      post :update, id: account.to_param, account: { about_raw: 'a' * 501 }

      assigns(:account).wont_be_nil
      assigns(:account).errors.wont_be_nil
      assigns(:account).errors.messages[:'markup.raw'].must_be :present?
      must_select "p.error[rel='markup.raw']", text: 'is too long (maximum is 500 characters)'
    end

    it 'must accept description within 500 characters' do
      post :update, id: account.to_param, account: {
        about_raw: 'a' * 99 + "\n" + 'a' * 99 + "\r" + 'a' * 300
      }
      must_redirect_to account
    end

    it 'must be successful' do
      location = 'Washington'
      post :update, id: account.to_param, account: { location: location }
      flash[:notice].must_equal 'Save successful!'
      account.reload.location.must_equal location
    end

    it 'must not allow updating other user\'s account' do
      post :update, id: create(:account).id, account: { location: :Wherever }
      must_redirect_to new_session_path
      flash.now[:error].must_match(/You can't edit another's account/)
    end
  end

  describe 'destroy' do
    it 'must allow deletion' do
      AnonymousAccount.create!
      account = create(:account)
      login_as account

      assert_difference 'Account.count', -1 do
        post :destroy, id: account.to_param
        must_redirect_to delete_feedback_accounts_path(account.login)
      end
    end

    it 'must not allow deletion by other accounts' do
      account = create(:account)
      login_as create(:account)

      assert_no_difference 'Account.count' do
        post :destroy, id: account.to_param
        flash.now[:error].must_match(/You can't edit another's account/)
      end
    end

    it 'while deleting an account, edits.account_id and edits.undone_by should be marked with Anonymous Coward ID' do
      skip 'Fix edits logic'
      project = create(:project)
      account = create(:account)
      login_as account
      anonymous_account_id = Account.find_or_create_anonymous_account.id
      Edit.delete_all

      manage = project.manages.create!(account: account)
      manage.update!(approved_by: account.id)
      project.update!(best_analysis_id: nil, editor_account: account)

      project.edits.first.account_id.must_equal account.id
      project.edits.first.undone_by.must_equal nil

      post :destroy, id: account.to_param

      project.edits.first.account_id.must_equal anonymous_account_id
    end

    it 'when deleting an account set the approved_by and deleted_by fields to Anonymous Coward ID' do
      skip 'Fix edits logic'
      project = create(:project)
      account = create(:account)
      login_as account
      Edit.delete_all

      manage = project.manages.create!(account: account)
      manage.update!(approved_by: account.id)
      project.update!(best_analysis_id: nil, editor_account: account)

      project.manages.wont_be :empty?

      post :destroy, id: account.to_param

      project.manages.must_be :empty?
    end
  end

  private

  def stub_verify_recaptcha_to_add_captcha_error
    AccountsController.any_instance.unstub(:verify_recaptcha)
    ApplicationController.class_eval do
      def verify_recaptcha(options)
        options[:model].errors.add(:captcha, 'some error')
      end
    end
  end
end
