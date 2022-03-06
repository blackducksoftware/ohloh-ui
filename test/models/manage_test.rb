# frozen_string_literal: true

require 'test_helper'

class ManageTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  before do
    @user1 = create(:account)
    @user2 = create(:account)
    @admin = create(:admin)
    @proj1 = create(:project)
    @proj2 = create(:project)
    @org = create(:organization)
  end

  it 'test create requires project' do
    manage = Manage.create(account: @admin)
    _(manage.errors).must_include(:target_type)
  end

  it 'test create requires account' do
    manage = Manage.create(target: @proj1)
    _(manage.errors).must_include(:account)
  end

  it 'test create should work' do
    manage = Manage.create(target: @proj1, account: @admin)
    manage.update!(approver: @user1)
    _(manage.errors.empty?).must_equal true
    _(@proj1.managers).must_include(@admin)
    _(@admin.projects).must_include(@proj1)
  end

  it 'test create should fail on maximum' do
    Manage.any_instance.expects(:over_management_limit?).returns(true)
    manage = Manage.create(account: @user2, target: @proj1)
    _(manage.errors).must_include(:maximum)
  end

  it 'test create fail on uniqueness' do
    Manage.create!(account: @admin, target: @proj1)
    manage = Manage.create(account: @admin, target: @proj1)
    _(manage.errors).must_include(:target_type)
  end

  it 'test add approver' do
    Manage.create!(account: @user2, target: @proj1)
    manage = Manage.create!(account: @admin, target: @proj1)
    _(manage.approver).must_be_nil
    manage.update!(approver: @user1)
    manage.reload
    _(manage.approver).must_equal @user1
  end

  it 'test active manager succeeds' do
    @proj1.manages.destroy_all
    manage = Manage.create!(account: @admin, target: @proj1)
    manage.update!(approver: @user1)
    _(@proj1.reload.active_managers).must_include(@admin)
  end

  it 'test active manager fails if deleted' do
    manage = Manage.create!(account: @admin, target: @proj1, deleted_at: Time.current)
    manage.update!(approver: @user1)
    _(@proj1.reload.active_managers).wont_include(@admin)
  end

  it 'test active manager includes auto approved' do
    manage = Manage.create!(account: @admin, target: @proj1)
    _(manage).wont_be_nil
    _(@proj1.reload.active_managers).must_include(@admin)
  end

  it 'test destroy_by! succeeds' do
    # make user an admin
    manage = Manage.create!(account: @user1, target: @proj1)
    manage.update!(approver: @admin)
    _(@proj1.reload.active_managers).must_include(@user1)

    # create a manage entry for admin
    manage = Manage.create!(account: @admin, target: @proj1)
    _(manage.destroyer).must_be_nil

    # user destroys it
    _(@proj1.reload.managers).must_include(@admin)
    manage.destroy_by!(@user1)
    _(@proj1.reload.managers).wont_include(@admin)
    _(manage.reload.destroyer).must_equal @user1
  end

  it 'test destroy_by! fails if destroyer isnt admin' do
    # create a manage entry for admin
    manage = Manage.create!(account: @admin, target: @proj1)
    manage.update!(approver: @user1)
    _(manage.destroyer).must_be_nil

    # user destroys it
    _(-> { manage.destroy_by!(@user1) }).must_raise(RuntimeError)
  end

  it 'test destroy_by! fails if destroyer isnt approved' do
    Manage.create!(account: @user2, target: @proj1) # auto-approved
    manage = Manage.create!(account: @user1, target: @proj1)
    _(@proj1.reload.active_managers).wont_include(@user1)

    # create a manage entry for admin
    manage = Manage.create!(account: @admin, target: @proj1)
    _(manage.destroyer).must_be_nil

    # user destroys it
    _(-> { manage.destroy_by!(@user1) }).must_raise(RuntimeError)
  end

  it 'test destroy_by! fails if destroyer deleted' do
    # make user an admin
    manage1 = Manage.create!(account: @user1, target: @proj1, deleted_at: Time.current)
    manage1.update!(approver: @user1)

    # create a manage entry for admin
    manage2 = Manage.create!(account: @admin, target: @proj1)
    _(manage2.destroyer).must_be_nil

    # user destroys it
    _(-> { manage2.destroy_by!(@user1) }).must_raise(RuntimeError)
  end

  it 'test bare destroy does not really destroy the object' do
    manage = create(:manage)
    manage.destroy
    manage = Manage.find(manage.id)
    _(manage.deleted_by).must_equal Account.hamster.id
  end

  it 'test pending fails if approved' do
    manage = Manage.create!(account: @user1, target: @proj1)
    manage.update!(approver: @user1)
    _(manage.pending?).must_equal false
  end

  it 'test pending fails if destroyed' do
    manage = Manage.create!(account: @user1, target: @proj1, destroyer: @user1)
    _(manage.pending?).must_equal false
  end

  it 'test pending fails if destroyed and approved' do
    manage = Manage.create!(account: @user1, target: @proj1, destroyer: @user1)
    manage.update!(approver: @user1)
    _(manage.pending?).must_equal false
  end

  it 'test approve!' do
    m1 = Manage.create!(target: @proj1, account: @admin)
    _(m1.approver).must_equal Account.hamster
    m2 = Manage.create!(target: @proj1, account: @user1)
    _(m2.approver).must_be_nil
    m2.approve!(@admin)
    _(@proj1.active_managers).must_include(@user1)
  end

  it 'test should list all the active managers for an organization' do
    @org.manages.destroy_all
    manage = Manage.create!(account: @admin, target: @org)
    Manage.create!(account: @user1, target: @proj1, approver: @admin)
    Manage.create!(account: @user2, target: @proj2, approver: @admin)
    manage.update!(approver: @user1)
    _(@org).must_equal @admin.reload.manages.organizations.first.target
    _(Manage.count).must_equal 3
    _(Manage.organizations.count).must_equal 1
  end

  it 'test rejection mail sent' do
    Manage.create!(account: @admin, target: @proj1)
    application = Manage.create!(account: @user1, target: @proj1)

    # sends one mail to admins (admin) and a different one to applicant (user)
    assert_emails 2 do
      application.update!(destroyer: @admin)
    end
  end

  it 'test approve mail sent' do
    Manage.create!(account: @admin, target: @proj1)
    application = Manage.create!(account: @user1, target: @proj1)

    # sends one mail to admins (admin) and a different one to applicant (user)
    assert_emails 1 do
      application.update!(approver: @admin)
    end
  end

  it 'test application mail sent 1' do
    Manage.create!(account: @admin, target: @proj1)

    # sends one mail to admin
    assert_emails 1 do
      Manage.create!(account: @user1, target: @proj1)
    end
  end

  it 'test application mail sent 2' do
    Manage.create!(account: @admin, target: @proj1)
    application = Manage.create!(account: @user1, target: @proj1)

    # sends one mail to admin
    assert_emails 1 do
      application.update!(destroyer: @user1)
    end
  end

  it 'test remove existing manager' do
    Manage.create!(account: @admin, target: @proj1)
    application = Manage.create!(account: @user1, target: @proj1, approver: @admin)
    _(@proj1.active_managers.count).must_equal 2

    # sends one mail to admins (admin) and a different one to applicant (user)
    assert_emails 2 do
      application.update!(destroyer: @user1)
    end
  end
end
