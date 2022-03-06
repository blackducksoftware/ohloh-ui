# frozen_string_literal: true

require 'test_helper'

class ApiKeyTest < ActiveSupport::TestCase
  it 'defaults are populated on new' do
    api_key = create(:api_key)
    _(api_key.daily_limit).must_equal ApiKey::DEFAULT_DAILY_LIMIT
    _(api_key.status).must_equal ApiKey::STATUS_OK
  end

  it 'may_i_have_another? when under limit' do
    api_key = create(:api_key)
    _(api_key.daily_count).must_equal 0
    _(api_key.may_i_have_another?).must_equal true
    _(api_key.daily_count).must_equal 1
  end

  it 'may_i_have_another? a new day dawns' do
    big_number = ApiKey::DEFAULT_DAILY_LIMIT * 2
    api_key = create(:api_key, day_began_at: Time.current - 1.year,
                               total_count: big_number,
                               daily_count: 27)
    _(api_key.may_i_have_another?).must_equal true
    _(api_key.total_count).must_equal big_number + 1
    _(api_key.daily_count).must_equal 1
  end

  it 'may_i_have_another? when reached limit' do
    api_key = create(:api_key, daily_count: ApiKey::DEFAULT_DAILY_LIMIT)
    _(api_key.may_i_have_another?).must_equal false
    api_key.reload
    _(api_key.daily_count).must_equal ApiKey::DEFAULT_DAILY_LIMIT
    _(api_key.total_count).must_equal 0
  end

  it 'may_i_have_another? false always for disabled_accounts' do
    api_key = create(:api_key, status: ApiKey::STATUS_DISABLED)
    _(api_key.may_i_have_another?).must_equal false
  end

  it 'may_i_have_another? a new day never dawns for disabled_accounts' do
    api_key = create(:api_key, day_began_at: Time.current - 1.year, status: ApiKey::STATUS_DISABLED)
    _(api_key.may_i_have_another?).must_equal false
  end

  it 'reset_all! works as expected' do
    day_began_at = Time.current - 1.year
    api_key1 = create(:api_key, daily_count: 2,
                                day_began_at: day_began_at)
    api_key2 = create(:api_key, daily_count: 3,
                                day_began_at: day_began_at,
                                status: ApiKey::STATUS_LIMIT_EXCEEDED)
    api_key3 = create(:api_key, daily_count: 4,
                                day_began_at: day_began_at,
                                status: ApiKey::STATUS_DISABLED)

    ApiKey.reset_all!
    api_key1.reload
    api_key2.reload
    api_key3.reload

    _(api_key1.daily_count).must_equal 0
    _(api_key1.day_began_at).wont_equal day_began_at
    _(api_key1.status).must_equal ApiKey::STATUS_OK

    _(api_key2.daily_count).must_equal 0
    _(api_key2.day_began_at).wont_equal day_began_at
    _(api_key2.status).must_equal ApiKey::STATUS_OK

    _(api_key3.daily_count).must_equal 0
    _(api_key3.day_began_at).wont_equal day_began_at
    _(api_key3.status).must_equal ApiKey::STATUS_DISABLED
  end

  it 'must successfully create a nested oauth application' do
    application_name = Faker::Company.name
    api_key = create(:api_key, oauth_application_attributes: { name: application_name,
                                                               redirect_uri: Faker::Internet.url })

    _(api_key.oauth_application.name).must_equal application_name
    _(api_key.oauth_application.uid).must_be :present?
    _(api_key.oauth_application.secret).must_be :present?
  end

  it 'must successfully update a nested oauth application' do
    api_key = create(:api_key)
    application_name = Faker::Company.name
    api_key.update!(oauth_application_attributes: { name: application_name,
                                                    redirect_uri: Faker::Internet.url })

    _(api_key.oauth_application.name).must_equal application_name
  end

  describe '#find_for_oauth_application_uid' do
    it 'must return the correct oauth_application' do
      api_key = create(:api_key)
      oauth_application_uid = Doorkeeper::Application.last.uid

      _(ApiKey.find_for_oauth_application_uid(oauth_application_uid)).must_equal api_key
    end
  end
end
