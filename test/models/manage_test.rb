require 'test_helper'

class ManageTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  before do
    @user1 = create(:account)
    @user2 = create(:account)
    @admin = create(:admin)
  end

  it 'test create requires project' do
    manage = Manage.create(account: @admin)
    manage.errors.must_include(:target)
  end

  it 'test create requires account' do
    manage = Manage.create(target: projects(:linux))
    manage.errors.must_include(:account)
  end

  it 'test create should work' do
    manage = Manage.create(target: projects(:linux), account: @admin)
    manage.update_attributes!(approver: @user1)
    manage.errors.empty?.must_equal true
    projects(:linux).managers.must_include(@admin)
    @admin.projects.must_include(projects(:linux))
  end

  it 'test create should fail on maximum' do
    Manage.any_instance.expects(:over_management_limit?).returns(true)
    manage = Manage.create(account: @user2, target: projects(:linux))
    manage.errors.must_include(:maximum)
  end

  it 'test create fail on uniqueness' do
    Manage.create!(account: @admin, target: projects(:linux))
    manage = Manage.create(account: @admin, target: projects(:linux))
    manage.errors.must_include(:target_id)
  end

  it 'test add approver' do
    Manage.create!(account: @user2, target: projects(:linux))
    manage = Manage.create!(account: @admin, target: projects(:linux))
    manage.approver.must_be_nil
    manage.update_attributes!(approver: @user1)
    manage.reload
    manage.approver.must_equal @user1
  end

  it 'test active manager succeeds' do
    projects(:linux).manages.destroy_all
    manage = Manage.create!(account: @admin, target: projects(:linux))
    manage.update_attributes!(approver: @user1)
    projects(:linux).reload.active_managers.must_include(@admin)
  end

  it 'test active manager fails if deleted' do
    manage = Manage.create!(account: @admin, target: projects(:linux), deleted_at: Time.now.utc)
    manage.update_attributes!(approver: @user1)
    projects(:linux).reload.active_managers.wont_include(@admin)
  end

  it 'test active manager includes auto approved' do
    manage = Manage.create!(account: @admin, target: projects(:linux))
    manage.wont_be_nil
    projects(:linux).reload.active_managers.must_include(@admin)
  end

  it 'test destroy by succeeds' do
    # make user an admin
    manage = Manage.create!(account: @user1, target: projects(:linux))
    manage.update_attributes!(approver: @admin)
    projects(:linux).reload.active_managers.must_include(@user1)

    # create a manage entry for admin
    manage = Manage.create!(account: @admin, target: projects(:linux))
    manage.destroyer.must_equal nil

    # user destroys it
    projects(:linux).reload.managers.must_include(@admin)
    manage.destroy_by!(@user1)
    projects(:linux).reload.managers.wont_include(@admin)
    manage.reload.destroyer.must_equal @user1
  end

  it 'test destroy by fails if destroyer isnt admin' do
    # create a manage entry for admin
    manage = Manage.create!(account: @admin, target: projects(:linux))
    manage.update_attributes!(approver: @user1)
    manage.destroyer.must_equal nil

    # user destroys it
    -> { manage.destroy_by!(@user1) }.must_raise(RuntimeError)
  end

  it 'test destroy by fails if destroyer isnt approved' do
    Manage.create!(account: @user2, target: projects(:linux)) # auto-approved
    manage = Manage.create!(account: @user1, target: projects(:linux))
    projects(:linux).reload.active_managers.wont_include(@user1)

    # create a manage entry for admin
    manage = Manage.create!(account: @admin, target: projects(:linux))
    manage.destroyer.must_equal nil

    # user destroys it
    -> { manage.destroy_by!(@user1) }.must_raise(RuntimeError)
  end

  it 'test destroy by fails if destroyer deleted' do
    # make user an admin
    manage1 = Manage.create!(account: @user1, target: projects(:linux), deleted_at: Time.now.utc)
    manage1.update_attributes!(approver: @user1)

    # create a manage entry for admin
    manage2 = Manage.create!(account: @admin, target: projects(:linux))
    manage2.destroyer.must_equal nil

    # user destroys it
    -> { manage2.destroy_by!(@user1) }.must_raise(RuntimeError)
  end

  it 'test pending fails if approved' do
    manage = Manage.create!(account: @user1, target: projects(:linux))
    manage.update_attributes!(approver: @user1)
    manage.pending?.must_equal false
  end

  it 'test pending fails if destroyed' do
    manage = Manage.create!(account: @user1, target: projects(:linux), destroyer: @user1)
    manage.pending?.must_equal false
  end

  it 'test pending fails if destroyed and approved' do
    manage = Manage.create!(account: @user1, target: projects(:linux), destroyer: @user1)
    manage.update_attributes!(approver: @user1)
    manage.pending?.must_equal false
  end

  it 'test approve!' do
    m1 = Manage.create!(target: projects(:linux), account: @admin)
    m1.approver.must_equal Account.hamster
    m2 = Manage.create!(target: projects(:linux), account: @user1)
    m2.approver.must_equal nil
    m2.approve!(@admin)
    projects(:linux).active_managers.must_include(@user1)
  end

  it 'test should list all the active managers for an organization' do
    organizations(:linux).manages.destroy_all
    manage = Manage.create!(account: @admin, target: organizations(:linux))
    Manage.create!(account: @user1, target: projects(:linux), approver: @admin)
    Manage.create!(account: @user2, target: projects(:adium), approver: @admin)
    manage.update_attributes!(approver: @user1)
    organizations(:linux).must_equal @admin.reload.manages.organizations.first.target
    Manage.count.must_equal 3
    Manage.organizations.count.must_equal 1
  end

  it 'test rejection mail sent' do
    Manage.create!(account: @admin, target: projects(:linux))
    application = Manage.create!(account: @user1, target: projects(:linux))

    # sends one mail to admins (admin) and a different one to applicant (user)
    assert_emails 2 do
      application.update_attributes!(destroyer: @admin)
    end
  end

  it 'test approve mail sent' do
    Manage.create!(account: @admin, target: projects(:linux))
    application = Manage.create!(account: @user1, target: projects(:linux))

    # sends one mail to admins (admin) and a different one to applicant (user)
    assert_emails 1 do
      application.update_attributes!(approver: @admin)
    end
  end

  it 'test application mail sent 1' do
    Manage.create!(account: @admin, target: projects(:linux))

    # sends one mail to admin
    assert_emails 1 do
      Manage.create!(account: @user1, target: projects(:linux))
    end
  end

  it 'test application mail sent 2' do
    Manage.create!(account: @admin, target: projects(:linux))
    application = Manage.create!(account: @user1, target: projects(:linux))

    # sends one mail to admin
    assert_emails 1 do
      application.update_attributes!(destroyer: @user1)
    end
  end

  it 'test remove existing manager' do
    Manage.create!(account: @admin, target: projects(:linux))
    application = Manage.create!(account: @user1, target: projects(:linux), approver: @admin)
    projects(:linux).active_managers.count.must_equal 2

    # sends one mail to admins (admin) and a different one to applicant (user)
    assert_emails 2 do
      application.update_attributes!(destroyer: @user1)
    end
  end
end
