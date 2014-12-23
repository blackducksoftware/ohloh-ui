require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  fixtures :accounts, :vitas, :name_facts, :projects, :commits, :analyses

  test '#sent_kudos' do
    Kudo.delete_all
    admin_account = accounts(:admin)
    create(:kudo, sender: admin_account, account: accounts(:user))
    create(:kudo, sender: admin_account, account: accounts(:joe))

    assert_equal 2, admin_account.sent_kudos.count
  end

  test '#claimed_positions' do
    create(:position, account: accounts(:user), project: projects(:ohloh))
    assert_equal 2, accounts(:user).positions.count
    assert_equal 1, accounts(:user).claimed_positions.count
  end

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
    expected_error_message =
      ['can\'t be blank', 'is too short (minimum is 3 characters)',
       I18n.t('activerecord.errors.models.account.attributes.login.invalid')]
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
    expected_error_message = ['can\'t be blank']
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

  test 'should search by login and sort by position and char length' do
    create(:account, login: 'test')
    create(:account, login: 'account_test', email: 'test2@openhub.net', email_confirmation: 'test2@openhub.net')
    create(:account, login: 'tester', email: 'test3@openhub.net', email_confirmation: 'test3@openhub.net')
    create(:account, login: 'unittest', email: 'test4@openhub.net', email_confirmation: 'test4@openhub.net')
    create(:account, login: 'unittest1', email: 'test5@openhub.net', email_confirmation: 'test5@openhub.net')
    account_search = Account.simple_search('test')
    assert_equal 5, account_search.size
    assert_equal 'test', account_search.first.login
    assert_equal 'tester', account_search.second.login
    assert_equal 'unittest', account_search.third.login
    assert_equal 'unittest1', account_search.fourth.login
    assert_equal 'account_test', account_search.fifth.login
  end

  test 'should return recently active accounts' do
    name_facts(:vitafact).update_attributes(last_checkin: Time.now)
    recently_active = Account.recently_active
    assert_not_nil recently_active
    assert_equal 1, recently_active.count
  end

  test 'should not return non recently active accounts' do
    recently_active = Account.recently_active
    assert_empty recently_active
    assert_equal 0, recently_active.count
  end

  test 'it should error out when affiliation_type is specified and org name is blank' do
    account = create(:account)
    account.affiliation_type = 'specified'
    account.organization_id = ''
    assert_not account.valid?
    assert_includes account.errors, :organization_id
    assert_equal ['can\'t be blank'], account.errors.messages[:organization_id]
  end

  test 'facts_joins should accounts with positions projects and name_facts' do
    analysis = analyses(:linux)
    project = projects(:linux)
    project.update_attributes! best_analysis_id: analysis.id

    accounts_with_facts = Account.with_facts
    assert_equal 2, accounts_with_facts.size
    assert_equal 'admin Allen', accounts_with_facts.first.name
    assert_equal 'user Luckey', accounts_with_facts.last.name
  end

  test 'should validate current password error message' do
    account = accounts(:user)
    account.current_password = 'dummy password'
    refute account.valid?
    assert_equal 1, account.errors.size
    assert_equal [I18n.t('activerecord.errors.models.account.attributes.current_password.invalid')],
                 account.errors[:current_password]
  end

  test 'should not raise error for valid current password' do
    account = accounts(:user)
    account.current_password = 'test'
    assert account.valid?
    assert_equal 0, account.errors.size
  end

  class LoginValidationsTest < AccountTest
    test 'test should require login' do
      assert_no_difference 'Account.count' do
        account = build(:account, login: nil)
        account.valid?
        assert account.errors.messages[:login].present?
      end
    end

    test 'test valid logins' do
      account = build(:account)
      logins = %w(rockola ROCKOLA Rockola Rock_Ola F323)

      logins.each do |login|
        account.login = login
        assert account.valid?
      end
    end

    test 'test login not urlable' do
      account = build(:account)
      bad_logins = %w(123 user.allen $foo])

      bad_logins.each do |bad_login|
        account.login = bad_login
        assert !account.valid?
      end
    end

    test 'test bad login on create' do
      account = build(:account, login: '$foo')
      account.valid?
      assert account.errors.messages[:login].present?
    end

    test 'test login on update' do
      # fake a bad login already in the db
      account = accounts(:user)
      account.login = '$bad_login$'
      assert account.save(validate: false)

      # ok, now update something else than login
      account.reload
      account.name = 'My New Name'
      assert account.save

      # ok, now try updating the name to something new, yet still wrong
      account.reload
      account.login = '$another_bad_login$'
      assert !account.save
      assert account.errors.messages[:login].present?
    end
  end
end
