require 'test_helper'

class ManageTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  it 'test create requires project' do
    manage = Manage.create(account: accounts(:admin))
    manage.errors.must_include(:target)
  end

  it 'test create requires account' do
    manage = Manage.create(target: projects(:linux))
    manage.errors.must_include(:account)
  end

  it 'test create should work' do
    manage = Manage.create(target: projects(:linux), account: accounts(:admin))
    manage.update_attributes!(approver: accounts(:user))
    manage.errors.empty?.must_equal true
    projects(:linux).managers.must_include(accounts(:admin))
    accounts(:admin).projects.must_include(projects(:linux))
  end

  it 'test create should fail on maximum' do
    Manage.any_instance.expects(:over_management_limit?).returns(true)
    manage = Manage.create(account: accounts(:joe), target: projects(:linux))
    manage.errors.must_include(:maximum)
  end

  it 'test create fail on uniqueness' do
    Manage.create!(account: accounts(:admin), target: projects(:linux))
    manage = Manage.create(account: accounts(:admin), target: projects(:linux))
    manage.errors.must_include(:target_id)
  end

  it 'test add approver' do
    Manage.create!(account: accounts(:joe), target: projects(:linux))
    manage = Manage.create!(account: accounts(:admin), target: projects(:linux))
    manage.approver.must_be_nil
    manage.update_attributes!(approver: accounts(:user))
    manage.reload
    manage.approver.must_equal accounts(:user)
  end

  it 'test active manager succeeds' do
    projects(:linux).manages.destroy_all
    manage = Manage.create!(account: accounts(:admin), target: projects(:linux))
    manage.update_attributes!(approver: accounts(:user))
    projects(:linux).reload.active_managers.must_include(accounts(:admin))
  end

  it 'test active manager fails if deleted' do
    manage = Manage.create!(account: accounts(:admin), target: projects(:linux), deleted_at: Time.now.utc)
    manage.update_attributes!(approver: accounts(:user))
    projects(:linux).reload.active_managers.wont_include(accounts(:admin))
  end

  it 'test active manager includes auto approved' do
    manage = Manage.create!(account: accounts(:admin), target: projects(:linux))
    manage.wont_be_nil
    projects(:linux).reload.active_managers.must_include(accounts(:admin))
  end

  it 'test destroy by succeeds' do
    # make user an admin
    manage = Manage.create!(account: accounts(:user), target: projects(:linux))
    manage.update_attributes!(approver: accounts(:admin))
    projects(:linux).reload.active_managers.must_include(accounts(:user))

    # create a manage entry for admin
    manage = Manage.create!(account: accounts(:admin), target: projects(:linux))
    manage.destroyer.must_equal nil

    # user destroys it
    projects(:linux).reload.managers.must_include(accounts(:admin))
    manage.destroy_by!(accounts(:user))
    projects(:linux).reload.managers.wont_include(accounts(:admin))
    manage.reload.destroyer.must_equal accounts(:user)
  end

  it 'test destroy by fails if destroyer isnt admin' do
    # create a manage entry for admin
    manage = Manage.create!(account: accounts(:admin), target: projects(:linux))
    manage.update_attributes!(approver: accounts(:user))
    manage.destroyer.must_equal nil

    # user destroys it
    -> { manage.destroy_by!(accounts(:user)) }.must_raise(RuntimeError)
  end

  it 'test destroy by fails if destroyer isnt approved' do
    Manage.create!(account: accounts(:joe), target: projects(:linux)) # auto-approved
    manage = Manage.create!(account: accounts(:user), target: projects(:linux))
    projects(:linux).reload.active_managers.wont_include(accounts(:user))

    # create a manage entry for admin
    manage = Manage.create!(account: accounts(:admin), target: projects(:linux))
    manage.destroyer.must_equal nil

    # user destroys it
    -> { manage.destroy_by!(accounts(:user)) }.must_raise(RuntimeError)
  end

  it 'test destroy by fails if destroyer deleted' do
    # make user an admin
    manage1 = Manage.create!(account: accounts(:user), target: projects(:linux), deleted_at: Time.now.utc)
    manage1.update_attributes!(approver: accounts(:user))

    # create a manage entry for admin
    manage2 = Manage.create!(account: accounts(:admin), target: projects(:linux))
    manage2.destroyer.must_equal nil

    # user destroys it
    -> { manage2.destroy_by!(accounts(:user)) }.must_raise(RuntimeError)
  end

  it 'test pending fails if approved' do
    manage = Manage.create!(account: accounts(:user), target: projects(:linux))
    manage.update_attributes!(approver: accounts(:user))
    manage.pending?.must_equal false
  end

  it 'test pending fails if destroyed' do
    manage = Manage.create!(account: accounts(:user), target: projects(:linux), destroyer: accounts(:user))
    manage.pending?.must_equal false
  end

  it 'test pending fails if destroyed and approved' do
    manage = Manage.create!(account: accounts(:user), target: projects(:linux), destroyer: accounts(:user))
    manage.update_attributes!(approver: accounts(:user))
    manage.pending?.must_equal false
  end

  it 'test approve!' do
    m1 = Manage.create!(target: projects(:linux), account: accounts(:admin))
    m1.approver.must_equal Account.hamster
    m2 = Manage.create!(target: projects(:linux), account: accounts(:user))
    m2.approver.must_equal nil
    m2.approve!(accounts(:admin))
    projects(:linux).active_managers.must_include(accounts(:user))
  end

  it 'test should list all the active managers for an organization' do
    organizations(:linux).manages.destroy_all
    manage = Manage.create!(account: accounts(:admin), target: organizations(:linux))
    Manage.create!(account: accounts(:user), target: projects(:linux), approver: accounts(:admin))
    Manage.create!(account: accounts(:joe), target: projects(:adium), approver: accounts(:admin))
    manage.update_attributes!(approver: accounts(:user))
    organizations(:linux).must_equal accounts(:admin).reload.manages.organizations.first.target
    Manage.count.must_equal 3
    Manage.organizations.count.must_equal 1
  end

  it 'test rejection mail sent' do
    Manage.create!(account: accounts(:admin), target: projects(:linux))
    application = Manage.create!(account: accounts(:user), target: projects(:linux))

    # sends one mail to admins (admin) and a different one to applicant (user)
    assert_emails 2 do
      application.update_attributes!(destroyer: accounts(:admin))
    end
  end

  it 'test approve mail sent' do
    Manage.create!(account: accounts(:admin), target: projects(:linux))
    application = Manage.create!(account: accounts(:user), target: projects(:linux))

    # sends one mail to admins (admin) and a different one to applicant (user)
    assert_emails 1 do
      application.update_attributes!(approver: accounts(:admin))
    end
  end

  it 'test application mail sent 1' do
    Manage.create!(account: accounts(:admin), target: projects(:linux))

    # sends one mail to admin
    assert_emails 1 do
      Manage.create!(account: accounts(:user), target: projects(:linux))
    end
  end

  it 'test application mail sent 2' do
    Manage.create!(account: accounts(:admin), target: projects(:linux))
    application = Manage.create!(account: accounts(:user), target: projects(:linux))

    # sends one mail to admin
    assert_emails 1 do
      application.update_attributes!(destroyer: accounts(:user))
    end
  end

  it 'test remove existing manager' do
    Manage.create!(account: accounts(:admin), target: projects(:linux))
    application = Manage.create!(account: accounts(:user), target: projects(:linux), approver: accounts(:admin))
    projects(:linux).active_managers.count.must_equal 2

    # sends one mail to admins (admin) and a different one to applicant (user)
    assert_emails 2 do
      application.update_attributes!(destroyer: accounts(:user))
    end
  end
end
