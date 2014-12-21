require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  fixtures :accounts, :invites

  class BeforeValidation < AccountTest
    test 'must strip login email and name' do
      account = accounts(:user)
      account.login = 'login    '
      account.email = '     email'
      account.name = '    name    '
      account.save
      assert_equal 'login', account.login
      assert_equal 'email', account.email
      assert_equal 'name', account.name
    end

    test 'must set name to login when it is blank' do
      account = build(:account)
      account.name = ''
      account.valid?
      assert_equal account.login, account.name
    end

    test 'must retain name when it is not blank' do
      account = build(:account)
      account.name = ' name '
      account.valid?
      assert_equal 'name', account.name
    end
  end

  class BeforeCreate < AccountTest
    test 'must set activation code to random hash' do
      account = create(:account)
      assert_not_empty account.activation_code
      assert_equal 40, account.activation_code.length
      assert_nil account.activation_code.match(/[^a-z0-9]/)
    end

    test 'must populate salt' do
      account = build(:account)
      account.save!

      assert_equal true, account.salt.present?
    end
  end

  class BeforeSave < AccountTest
    test 'must not change salt' do
      account = accounts(:user)
      account.password = 'new_password'
      account.password_confirmation = 'new_password'
      original_salt = account.salt

      account.save!

      assert_equal original_salt, account.salt
    end

    test 'must not change crypted_password when password is blank' do
      account = accounts(:uber_data_crawler)
      account.password = nil
      account.password_confirmation = nil
      original_crypted_password = account.crypted_password

      account.save!

      assert_equal original_crypted_password, account.crypted_password
    end

    test 'must change crypted_password if password is not blank' do
      account = accounts(:uber_data_crawler)
      account.password = 'new_password'
      account.password_confirmation = 'new_password'
      original_crypted_password = account.crypted_password

      account.save!

      assert_not_equal original_crypted_password, account.crypted_password
    end

    test 'must encrypt email when it changes' do
      account = accounts(:user)
      original_email_md5 = account.email_md5
      account.email = Faker::Internet.email
      account.save!

      assert_not_equal original_email_md5, account.email_md5
    end

    test 'must not encrypt email when it has not changed' do
      account = accounts(:user)
      account.expects(:encrypt_email).never
      account.save!
    end
  end

  class AfterCreate < AccountTest
    test 'must change invitee id and activated date' do
      account = build(:account)
      account.no_email = false
      invite = invites(:user)
      invitee_id = invite.invitee_id
      account.invite_code = invite.activation_code
      account.save

      assert_not_equal invites(:user).reload.invitee_id, invitee_id
      assert_equal invites(:user).invitee_id, account.id
    end

    test 'must create person for non spam account' do
      account = build(:account, level: Account::DEFAULT_LEVEL)
      account.no_email = false

      assert_difference('Person.count', 1) do
        account.save
      end
    end

    test 'must not create person for spam account' do
      account = build(:account, level: Account::SPAMMER_LEVEL)
      account.no_email = false

      assert_no_difference('Person.count') do
        account.save
      end
    end

    test 'should rollback when notification raises an error' do
      skip('TODO: AccountNotifier')

      account = build(:account, level: Account::DEFAULT_LEVEL)
      account.no_email = true
      AccountNotifier.stubs(:deliver_signup_notification)
                     .raises(Net::SMTPSyntaxError.new('Bad recipient address syntax'))

      assert_no_difference('Person.count') do
        Account.transaction do
          account.save
        end
      end

      assert_equal 1, account.errors.size
      # assert_equal ["The Black Duck Open Hub could not send
      # registration email to <strong class='red'>uber@ohloh.net</strong>.
      # Invalid Email Address provided."], account.errors['email']
    end
  end

  class AfterUpdate < AccountTest
    test 'should schedule organization analysis on update' do
      skip('FIXME: add test when implementing schedule_analysis')
    end
  end

  class AfterSave < AccountTest
    test 'must update persons effective_name after save' do
      account = accounts(:user)
      assert_equal 'Robin Luckey', account.person.effective_name
      account.save!
      assert_equal 'user Luckey', account.person.effective_name
    end
  end

  test 'sent_kudos' do
    Kudo.delete_all
    admin_account = accounts(:admin)
    create(:kudo, sender: admin_account, account: accounts(:user))
    create(:kudo, sender: admin_account, account: accounts(:joe))

    assert_equal 2, admin_account.sent_kudos.count
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
