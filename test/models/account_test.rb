require_relative '../test_helper'

class AccountTest < ActiveSupport::TestCase
  test 'the account model should be valid' do
    account = build(:account)
    assert true, account.valid?
  end

  test 'it should validate email and email_confirmation' do
    account = build(:account, email: 'ab')
    assert_not account.valid?
    assert_includes account.errors, :email
    assert_includes account.errors, :email_confirmation
    expected_error_message = ['is too short (minimum is 3 characters)', I18n.t('accounts.invalid_email_address')]
    assert_equal expected_error_message, account.errors.messages[:email]
    assert_equal ['doesn\'t match Email'], account.errors.messages[:email_confirmation]
  end

  test 'it should validate URL format when value is available' do
    account = build(:account)
    assert account.valid?

    account = build(:account, url: '')
    assert account.valid?

    account = build(:account, url: 'openhub.net')
    assert_not account.valid?
    assert_includes account.errors, :url
    assert_equal ['Invalid URL Format'], account.errors.messages[:url]
  end

  test 'it should validate login' do
    account = build(:account)
    assert account.valid?

    account = build(:account, login: '')
    assert_not account.valid?
    expected_error_message = ['can\'t be blank', 'is too short (minimum is 3 characters)']
    assert_equal expected_error_message, account.errors.messages[:login]

    create(:account, login: 'openhub_dev')
    account = build(:account, login: 'openhub_dev')
    assert_not account.valid?
    assert_includes account.errors, :login
    assert_equal ['has already been taken'], account.errors.messages[:login]
  end

  test 'it should validate password' do
    account = build(:account)
    assert account.valid?

    account = build(:account, password: '')
    assert_not account.valid?
    expected_error_message = ['can\'t be blank', 'is too short (minimum is 5 characters)']
    assert_includes account.errors, :password
    assert_equal expected_error_message, account.errors.messages[:password]
    assert_equal ['doesn\'t match Password'], account.errors.messages[:password_confirmation]

    account = build(:account, password: 'abc12345', password_confirmation: 'ABC12345')
    assert_not account.valid?
    assert_includes account.errors, :password_confirmation
    assert_equal ['doesn\'t match Password'], account.errors.messages[:password_confirmation]
  end

  test 'it should validate twitter account only if its present' do
    account = build(:account)
    assert account.valid?

    account = build(:account, twitter_account: '')
    assert account.valid?

    account = build(:account, twitter_account: 'abcdefghijklmnopqrstuvwxyz')
    assert_not account.valid?
    assert_includes account.errors, :twitter_account
    assert_equal ['is too long (maximum is 15 characters)'], account.errors.messages[:twitter_account]
  end

  test 'it should validate user full name' do
    account = build(:account)
    assert account.valid?

    account = build(:account, name: '')
    assert account.valid?

    account = build(:account, name: Faker::Name.name * 8)
    assert_not account.valid?
    assert_includes account.errors, :name
    assert_equal ['is too long (maximum is 50 characters)'], account.errors.messages[:name]
  end

  test 'it should update the markup(about me) when updating a record' do
    account = create(:account)
    about_me = Faker::Lorem.paragraph(2)
    account.about_raw = about_me
    account.save
    assert_equal about_me, account.about_raw
  end

  test 'it should not update the markup(about me) when exceeding the limit' do
    account = create(:account)
    about_me = Faker::Lorem.paragraph(130)
    account.about_raw = about_me
    assert_not account.valid?
    assert_includes account.markup.errors, :raw
  end

  test 'it should error out when affiliation_type is not specified' do
    account = create(:account)
    account.affiliation_type = ''
    assert_not account.valid?
    assert_includes account.errors, :affiliation_type
    assert_equal ['is invalid'], account.errors.messages[:affiliation_type]
  end

  test 'it should error out when affiliation_type is specified and org name is blank' do
    account = create(:account)
    account.affiliation_type = 'specified'
    account.organization_id = ''
    assert_not account.valid?
    assert_includes account.errors, :organization_id
    assert_equal ['can\'t be blank'], account.errors.messages[:organization_id]
  end
end
