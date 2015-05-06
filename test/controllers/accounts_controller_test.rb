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

  describe 'unsubscribe_emails' do
    it 'a valid key for a account should unsubscribe the user' do
      key = Ohloh::Cipher.encrypt(create(:account).id.to_s)
      get :unsubscribe_emails, key: CGI.unescape(key)
      must_respond_with :ok
      assigns(:account).email_master.must_equal false
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

  describe 'new' do
    it 'must respond with success' do
      get :disabled, id: create(:spammer).to_param
      must_respond_with :success
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

    it 'should update email master to false' do
      put :update, id: account.id, account: { email_master: false }
      account.save!
      account.reload
      account.email_master.must_equal false
      flash[:notice].must_equal 'Save successful!'
    end

    it 'should update email master to true if set to false' do
      account.email_master = false
      put :update, id: account.id, account: { email_master: true }
      account.reload
      account.email_master.must_equal true
      flash[:notice].must_equal 'Save successful!'
    end

    it 'should update email kudos to false' do
      put :update, id: account.id, account: { email_kudos: false }
      account.save!
      account.reload
      account.email_kudos.must_equal false
      flash[:notice].must_equal 'Save successful!'
    end

    it 'should update email kudos to true if set to false' do
      account.email_kudos = false
      put :update, id: account.id, account: { email_kudos: true }
      account.reload
      account.email_kudos.must_equal true
      flash[:notice].must_equal 'Save successful!'
    end

    it 'should update email posts to false' do
      put :update, id: account.id, account: { email_posts: false }
      account.save!
      account.reload
      account.email_posts.must_equal false
      flash[:notice].must_equal 'Save successful!'
    end

    it 'should update email posts to true if set to false' do
      account.email_posts = false
      put :update, id: account.id, account: { email_posts: true }
      account.reload
      account.email_posts.must_equal true
      flash[:notice].must_equal 'Save successful!'
    end
  end

  describe 'destroy' do
    it 'must allow deletion' do
      AnonymousAccount.create!
      account = create(:account)
      login_as account

      assert_difference 'Account.count', -1 do
        post :destroy, id: account.to_param
        must_redirect_to edit_deleted_account_path(account.login)
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

  describe 'settings' do
    it 'should render settings' do
      get :settings, id: user.id
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
