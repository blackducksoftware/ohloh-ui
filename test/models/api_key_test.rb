require 'test_helper'

class ApiKeyTest < ActiveSupport::TestCase
  test 'defaults are populated on new' do
    api_key = create(:api_key)
    assert_equal ApiKey::DEFAULT_DAILY_LIMIT, api_key.daily_limit
    assert_equal ApiKey::STATUS_OK, api_key.status
  end

  test 'may_i_have_another? when under limit' do
    api_key = create(:api_key)
    assert_equal 0, api_key.daily_count
    assert_equal true, api_key.may_i_have_another?
    assert_equal 1, api_key.daily_count
  end

  test 'may_i_have_another? a new day dawns' do
    big_number = ApiKey::DEFAULT_DAILY_LIMIT * 2
    api_key = create(:api_key, day_began_at: Time.now - 1.year,
                               total_count: big_number,
                               daily_count: 27)
    assert_equal true, api_key.may_i_have_another?
    assert_equal big_number + 1, api_key.total_count
    assert_equal 1, api_key.daily_count
  end

  test 'may_i_have_another? when reached limit' do
    api_key = create(:api_key, daily_count: ApiKey::DEFAULT_DAILY_LIMIT)
    assert_equal false, api_key.may_i_have_another?
  end

  test 'may_i_have_another? false always for disabled_accounts' do
    api_key = create(:api_key, status: ApiKey::STATUS_DISABLED)
    assert_equal false, api_key.may_i_have_another?
  end

  test 'may_i_have_another? a new day never dawns for disabled_accounts' do
    api_key = create(:api_key, day_began_at: Time.now - 1.year, status: ApiKey::STATUS_DISABLED)
    assert_equal false, api_key.may_i_have_another?
  end

  test 'reset_all! works as expected' do
    day_began_at = Time.now.utc - 1.year
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

    assert_equal 0, api_key1.daily_count
    assert_not_equal day_began_at, api_key1.day_began_at
    assert_equal ApiKey::STATUS_OK, api_key1.status

    assert_equal 0, api_key2.daily_count
    assert_not_equal day_began_at, api_key2.day_began_at
    assert_equal ApiKey::STATUS_OK, api_key2.status

    assert_equal 0, api_key3.daily_count
    assert_not_equal day_began_at, api_key3.day_began_at
    assert_equal ApiKey::STATUS_DISABLED, api_key3.status
  end
end
