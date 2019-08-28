# frozen_string_literal: true

require 'test_helper'

class Account::HooksTest < ActiveSupport::TestCase
  describe 'before_validation' do
    it 'must strip login email and name' do
      account = create(:account, login: 'login   ', email: '   email@test.com', name: '  name  ')
      account.login.must_equal 'login'
      account.email.must_equal 'email@test.com'
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
      account = create(:account)
      create_list(:topic, 3, account: account)
      create_list(:post, 3, account: account)
      create_position(account: account)
      create(:manage, account: account)

      # Create all types of edits to assert that every edit can be undone.
      Project.last.update!(description: Faker::Lorem.sentence, editor_account: account)
      ProjectLicense.create!(project: Project.last, license: create(:license), editor_account: account)
      account.edits.not_undone.map(&:type).sort.must_equal %w[CreateEdit PropertyEdit]

      account.verifications.count.must_equal 1
      account.topics.count.must_equal 3
      account.person.wont_be_nil
      account.positions.count.must_equal 1
      account.posts.count.must_equal 3
      account.manages.count.must_equal 1
      account.edits.not_undone.count.must_equal 2

      Project.any_instance.stubs(:edit_authorized?).returns(true)
      account.access.spam!
      account.reload
      account.access.spam?.must_equal true

      # verifications must be retained.
      account.verifications.count.must_equal 1
      account.topics.count.must_equal 0
      account.person.must_be_nil
      account.positions.count.must_equal 0
      account.posts.count.must_equal 0
      account.manages.count.must_equal 0
      # edits must be undone but still belong to spam account.
      account.edits.not_undone.count.must_equal 0
      account.edits.count.must_equal 2
    end

    it 'should rollback when destroy dependencies raises an exception' do
      topic = create(:topic, :with_posts)
      account = topic.account
      create(:topic, :with_posts, account: account)
      create_position(account: account)
      Account::Access.any_instance.stubs(:spam?).returns(true)
      Account.any_instance.stubs(:api_keys).raises(ActiveRecord::Rollback)
      account.topics.update_all(posts_count: 0)
      account.topics.count.must_equal 2
      account.person.wont_be_nil
      account.positions.count.must_equal 1
      account.save
      account.reload
      account.topics.count.must_equal 2
      account.person.wont_be_nil
      account.positions.count.must_equal 1
    end

    it 'should destroy dependencies before account destroy' do
      account = create(:account)
      topic = create(:topic, account: account)
      Post.create(topic: topic, account: account, body: 'test1')
      Post.create(topic: topic, account: account, body: 'test2')

      create_position(account: account)
      account.positions.count.must_equal 1
      account.posts.count.must_equal 2
      Account.find_or_create_anonymous_account.posts.count.must_equal 0
      assert_difference('DeletedAccount.count', 1) do
        account.destroy
      end
      account.verifications.must_be :empty?
      account.positions.count.must_equal 0
      account.posts.count.must_equal 0
      Account.find_or_create_anonymous_account.posts.count.must_equal 2
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

    it 'must request for email address verification' do
      account = build(:account, activated_at: nil)

      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        account.save!
      end

      email = ActionMailer::Base.deliveries.last
      email.to.must_equal [account.email]
      email.body.raw_source.must_match I18n.t('account_mailer.signup_notification.body', login: account.login)
    end

    it 'wont request email address verification when activation_at is already set' do
      assert_no_difference('ActionMailer::Base.deliveries.size') do
        create(:account, activated_at: Time.current)
      end
    end
  end

  describe 'after_update' do
    it 'should schedule organization analysis on update' do
      account = create(:account)

      Organization.any_instance.expects(:schedule_analysis).once
      account.update!(organization_id: create(:organization).id)
    end
  end

  describe 'after_save' do
    it 'must update persons effective_name after save' do
      account = create(:account, name: 'test name')
      account.person.effective_name.must_equal 'test name'
      account.update! name: 'test new name'
      account.person.effective_name.must_equal 'test new name'
    end
  end
end
