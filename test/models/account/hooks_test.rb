require 'test_helper'

class Account::HooksTest < ActiveSupport::TestCase
  describe 'before_validation' do
    it 'must strip login email and name' do
      account = accounts(:user)
      account.login = 'login    '
      account.email = '     email'
      account.name = '    name    '
      account.save
      account.login.must_equal 'login'
      account.email.must_equal 'email'
      account.name.must_equal 'name'
    end

    it 'must set name to login when it is blank' do
      account = build(:account)
      account.name = ''
      account.valid?
      account.name.must_equal account.login
    end

    it 'must set organization_name to nil when affiliation_type is not other' do
      account = build(:account)
      account.affiliation_type = 'specified'
      account.organization_name = 'org'
      account.organization_id = 1
      account.valid?

      account.organization_id.must_equal 1
      account.organization_name.must_be_nil
    end

    it 'must set organization_id to nil when affiliation_type is other' do
      account = build(:account)
      account.affiliation_type = 'other'
      account.organization_id = 1
      account.organization_name = 'org'
      account.valid?

      account.organization_id.must_be_nil
      account.organization_name.must_equal 'org'
    end
  end

  describe 'before_destroy' do
    it 'should destroy dependencies when marked as spam' do
      account = accounts(:user)
      Account::Access.any_instance.stubs(:spam?).returns(true)
      account.topics.update_all(posts_count: 0)
      account.topics.count.must_equal 3
      account.person.wont_be_nil
      account.positions.count.must_equal 1
      account.save!
      account.reload
      account.topics.count.must_equal 0
      account.person.must_be_nil
      account.positions.count.must_equal 0
    end

    it 'should rollback when destroy dependencies raises an exception' do
      account = accounts(:user)
      Account::Access.any_instance.stubs(:spam?).returns(true)
      Account.any_instance.stubs(:api_keys).raises(ActiveRecord::Rollback)
      account.topics.update_all(posts_count: 0)
      account.topics.count.must_equal 3
      account.person.wont_be_nil
      account.positions.count.must_equal 1
      account.save
      account.reload
      account.topics.count.must_equal 3
      account.person.wont_be_nil
      account.positions.count.must_equal 1
    end

    it 'should destroy dependencies before account destroy' do
      account = accounts(:user)
      account.positions.count.must_equal 1
      account.posts.count.must_equal 5
      Account.find_or_create_anonymous_account.posts.count.must_equal 0
      assert_difference('DeletedAccount.count', 1) do
        account.destroy
      end
      account.positions.count.must_equal 0
      account.posts.count.must_equal 0
      # TODO: Pass this test while integrating acts_as_editable.
      # Account.find_or_create_anonymous_account.posts.count.must_equal 5
    end
  end

  describe 'after_create' do
    it 'must change invitee id and activated date' do
      invite = create(:invite)
      account = create(:account, activated_at: nil, activation_code: 'activate_using_invite',
                                 invite_code: invite.activation_code, email: invite.invitee_email)
      invite.reload.invitee_id.must_equal account.id
    end

    it 'must create person for non spam account' do
      account = build(:account, level: Account::Access::DEFAULT)

      assert_difference('Person.count', 1) do
        account.save
      end
    end

    it 'must not create person for spam account' do
      account = build(:account, level: Account::Access::SPAM)

      assert_no_difference('Person.count') do
        account.save
      end
    end

    it 'should rollback when notification raises an error' do
      skip('TODO: AccountNotifier')

      account = build(:account, level: Account::Access::DEFAULT)
      AccountNotifier.stubs(:deliver_signup_notification)
        .raises(Net::SMTPSyntaxError.new('Bad recipient address syntax'))

      assert_no_difference('Person.count') do
        Account.transaction do
          account.save
        end
      end

      account.errors.size.must_equal 1
      # account.errors['email'].must_equal [
      # "The Black Duck Open Hub could not send registration email to
      # <strong class='red'>uber@ohloh.net</strong>.
      # Invalid Email Address provided."]
    end
  end

  describe 'after_update' do
    it 'should schedule organization analysis on update' do
      skip('FIXME: add test when implementing schedule_analysis')
    end
  end

  describe 'after_save' do
    it 'must update persons effective_name after save' do
      account = accounts(:user)
      account.person.effective_name.must_equal 'Robin Luckey'
      account.save!
      account.person.effective_name.must_equal 'user Luckey'
    end
  end
end
