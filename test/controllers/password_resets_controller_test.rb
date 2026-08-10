# frozen_string_literal: true

require 'test_helper'

class PasswordResetsControllerTest < ActionController::TestCase
  describe 'create' do
    it 'must send the password reset email' do
      account = create(:account)

      post :create, params: { password: { email: account.email } }

      email = ActionMailer::Base.deliveries.last
      _(email.subject).must_match I18n.t('clearance.models.clearance_mailer.change_password')
    end

    it 'must block request at 29 seconds (before cooldown expires)' do
      account = create(:account)
      base_time = Time.current
      travel_to base_time do
        account.update_columns(password_reset_requested_at: base_time)
      end

      travel_to base_time + 29.seconds do
        post :create, params: { password: { email: account.email } }
        _(response.status).must_equal 429
        _(flash[:error]).must_match(/wait.*seconds/)
      end
    end

    it 'must allow request after 30 seconds (cooldown expires)' do
      account = create(:account)
      base_time = Time.current
      travel_to base_time do
        account.update_columns(password_reset_requested_at: base_time)
      end

      travel_to base_time + 31.seconds do
        post :create, params: { password: { email: account.email } }
        _(response.status).must_equal 202
        email = ActionMailer::Base.deliveries.last
        _(email.subject).must_match I18n.t('clearance.models.clearance_mailer.change_password')
      end
    end

    it 'must block 4th request when 3 already sent within window' do
      account = create(:account)
      base_time = Time.current
      travel_to base_time do
        account.update_columns(password_reset_count: 3, password_reset_requested_at: base_time)
      end

      travel_to base_time + 35.seconds do
        post :create, params: { password: { email: account.email } }
        _(response.status).must_equal 429
        _(flash[:error]).must_equal I18n.t('passwords.create.rate_limit_exceeded')
      end
    end

    it 'must block at exactly 10 minute boundary' do
      account = create(:account)
      base_time = Time.current
      travel_to base_time do
        account.update_columns(password_reset_count: 3, password_reset_requested_at: base_time)
      end

      travel_to base_time + 10.minutes do
        post :create, params: { password: { email: account.email } }
        _(response.status).must_equal 429
        _(flash[:error]).must_equal I18n.t('passwords.create.rate_limit_exceeded')
      end
    end

    it 'must allow request just after 10 minute boundary' do
      account = create(:account)
      base_time = Time.current
      travel_to base_time do
        account.update_columns(password_reset_count: 3, password_reset_requested_at: base_time)
      end

      travel_to base_time + 10.minutes + 1.second do
        post :create, params: { password: { email: account.email } }
        _(response.status).must_equal 202
        email = ActionMailer::Base.deliveries.last
        _(email.subject).must_match I18n.t('clearance.models.clearance_mailer.change_password')
      end
    end

    it 'must block just before 10 minute boundary (still in window)' do
      account = create(:account)
      base_time = Time.current
      travel_to base_time do
        account.update_columns(password_reset_count: 3, password_reset_requested_at: base_time)
      end

      travel_to base_time + 10.minutes - 1.second do
        post :create, params: { password: { email: account.email } }
        _(response.status).must_equal 429
        _(flash[:error]).must_equal I18n.t('passwords.create.rate_limit_exceeded')
      end
    end

    it 'must increment counter within window' do
      account = create(:account)
      base_time = Time.current
      travel_to base_time do
        account.update_columns(password_reset_count: 1, password_reset_requested_at: base_time)
      end

      travel_to base_time + 35.seconds do
        post :create, params: { password: { email: account.email } }
        account.reload
        _(account.password_reset_count).must_equal 2
      end
    end

    it 'must not rate limit unknown email' do
      post :create, params: { password: { email: 'unknown@example.com' } }

      _(response.status).must_equal 202
      _(flash[:error]).wont_match(/rate_limit/)
    end

    it 'must reset counter after window expires' do
      account = create(:account)
      base_time = Time.current
      travel_to base_time do
        account.update_columns(password_reset_count: 3, password_reset_requested_at: base_time)
      end

      travel_to base_time + 10.minutes + 1.second do
        post :create, params: { password: { email: account.email } }
        account.reload
        _(account.password_reset_count).must_equal 1
      end
    end

    it 'must handle multiple rapid requests within cooldown' do
      account = create(:account)
      base_time = Time.current
      travel_to base_time do
        post :create, params: { password: { email: account.email } }
      end

      travel_to base_time + 5.seconds do
        post :create, params: { password: { email: account.email } }
        _(response.status).must_equal 429
      end

      travel_to base_time + 10.seconds do
        post :create, params: { password: { email: account.email } }
        _(response.status).must_equal 429
      end
    end

    it 'must block when email has uppercase characters' do
      account = create(:account, email: 'Test@Example.com')
      base_time = Time.current
      travel_to base_time do
        account.update_columns(password_reset_requested_at: base_time)
      end

      travel_to base_time + 5.seconds do
        post :create, params: { password: { email: 'TEST@EXAMPLE.COM' } }
        _(response.status).must_equal 429
      end
    end

    it 'must handle nil password_reset_requested_at for first request' do
      account = create(:account)
      account.update_columns(password_reset_requested_at: nil, password_reset_count: 0)

      post :create, params: { password: { email: account.email } }
      _(response.status).must_equal 202
      email = ActionMailer::Base.deliveries.last
      _(email.subject).must_match I18n.t('clearance.models.clearance_mailer.change_password')
    end
  end

  describe 'update' do
    it 'find the user for update' do
      Account.any_instance.stubs(:update_password)

      account = create(:account)
      account.update!(confirmation_token: Clearance::Token.new)

      put :update, params: { account_id: account.login, token: account.confirmation_token,
                             password_reset: { password: Faker::Internet.password } }

      _(assigns(:user).id).must_equal account.id
    end

    it 'must render error when token is expired' do
      Account.any_instance.stubs(:update_password)

      account = create(:account)
      account.update!(confirmation_token: Clearance::Token.new)

      put :update, params: { account_id: account.login, token: Faker::Internet.password,
                             password_reset: { password: Faker::Internet.password } }

      assert_template 'passwords/new'
      _(flash[:error]).must_equal I18n.t('passwords.token_expired_error')
    end
  end
end
