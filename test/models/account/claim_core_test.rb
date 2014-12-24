require 'test_helper'

class ClaimCoreTest < ActiveSupport::TestCase
  fixtures :accounts, :projects, :name_facts, :commits, :names, :positions

  test 'email ids' do
    projects(:linux).update!(best_analysis_id: 1)
    assert_equal [], accounts(:user).claim_core.email_ids
    assert_equal [], accounts(:unactivated).claim_core.emails # no positions

    email = create(:email_address, address: 'test@test.com')
    name_facts(:user).update_attribute(:email_address_ids, "{#{email.id}}")
    accounts(:user).claim_core.instance_variable_set('@name_fact_emails', nil)
    assert_equal [email.id], accounts(:user).claim_core.email_ids

    # claim a new position on a different project
    email_1 = create(:email_address, address: 'test1@test.com')
    user, adium = accounts(:user), projects(:adium)
    with_editor(:admin) do
      commits(:adium1).update_attribute(:email_address_id, email_1.id)
      adium.update_attribute(:deleted, false)
      # FIXME: Remove start_fix..end_fix blocks after integrating analysis.
      # adium.analyze
    end
    position = adium.positions.create(account: user, name: names(:user))
    # start_fix:
    adium.update!(best_analysis_id: Analysis.last.id)
    name_fact = NameFact.all.find { |nf| nf.email_address_ids.empty? }
    name_fact.update!(email_address_ids: [EmailAddress.last.id],
                      name_id: position.name_id)
    # end_fix:
    accounts(:user).claim_core.instance_variable_set('@name_fact_emails', nil)
    assert_equal [email.id, email_1.id], user.claim_core.email_ids

    # destroy the position and re-check
    user.positions.find_by_project_id(adium.id).destroy
    # start_fix:
    name_fact.update!(name_id: nil)
    # end_fix:
    accounts(:user).claim_core.instance_variable_set('@name_fact_emails', nil)
    assert_equal [email.id], accounts(:user).claim_core.email_ids

    # update the position name_id
    positions(:user).update_attribute(:name_id, names(:scott).id)
    name_facts(:unclaimed).update_attribute(:email_address_ids, "{#{email_1.id}}")
    accounts(:user).claim_core.instance_variable_set('@name_fact_emails', nil)
    assert_equal [email_1.id], accounts(:user).claim_core.email_ids
  end

  test 'email_ids for multiple positions or alias' do
    linux, user, scott = projects(:linux), accounts(:user), names(:scott)
    email = create(:email_address, address: 'test@test.com')
    email_1 = create(:email_address, address: 'test1@test.com')
    name_facts(:unclaimed).update_attribute(:email_address_ids, "{#{email.id}}")
    assert_equal [], user.claim_core.email_ids

    # alias scott as user. scott is associated with email - email
    alias_object = with_editor(:user) do
      create(:alias, commit_name_id: scott.id, preferred_name_id: names(:user).id, project_id: linux.id)
    end
    linux.update!(best_analysis_id: Analysis.last.id)
    user.claim_core.instance_variable_set('@name_fact_emails', nil)
    assert_equal [email.id], user.claim_core.email_ids

    # delete the alias
    alias_object.stubs(:create_edit).returns(stub(:undo))
    with_editor(:user) { alias_object.create_edit.undo }
    # FIXME: Remove after integrating analysis logic
    linux.update!(best_analysis_id: nil)
    user.claim_core.instance_variable_set('@name_fact_emails', nil)
    assert_equal [], user.claim_core.email_ids

    # aliasing scott as admin shouldn't affect user's claimed email ids
    alias_object.update!(preferred_name_id: names(:admin).id)
    user.claim_core.instance_variable_set('@name_fact_emails', nil)
    assert_equal [], user.claim_core.email_ids

    # bring back the old alias
    alias_object.update!(preferred_name_id: names(:user).id)
    linux.update!(best_analysis_id: Analysis.last.id)
    user.claim_core.instance_variable_set('@name_fact_emails', nil)
    assert_equal [email.id], user.claim_core.email_ids

    # with multiple email ids
    name_facts(:user).update_attribute(:email_address_ids, "{#{email_1.id}}")
    user.claim_core.instance_variable_set('@name_fact_emails', nil)
    assert_equal [email.id, email_1.id], user.claim_core.email_ids

    # with same email ids
    name_facts(:user).update_attribute(:email_address_ids, "{#{email.id}}")
    user.claim_core.instance_variable_set('@name_fact_emails', nil)
    assert_equal [email.id], user.claim_core.email_ids
  end

  test 'email_ids for deleted project' do
    projects(:linux).update!(best_analysis_id: Analysis.last.id)
    email = create(:email_address, address: 'test@test.com')
    name_facts(:user).update_attribute(:email_address_ids, "{#{email.id}}")
    assert_equal [email.id], accounts(:user).claim_core.email_ids

    with_editor(:user) { projects(:linux).update!(deleted: true) }
    accounts(:user).claim_core.instance_variable_set('@name_fact_emails', nil)
    assert_equal [], accounts(:user).claim_core.email_ids

    # add it back
    with_editor(:user) { projects(:linux).update!(deleted: false) }
    accounts(:user).claim_core.instance_variable_set('@name_fact_emails', nil)
    assert_equal [email.id], accounts(:user).claim_core.email_ids
  end

  test 'claimed_emails' do
    projects(:linux).update!(best_analysis_id: Analysis.last.id)
    assert_equal [], accounts(:user).claim_core.emails
    assert_equal [], accounts(:unactivated).claim_core.emails # no positions

    email = create(:email_address, address: 'test@test.com')
    name_facts(:user).update_attribute(:email_address_ids, "{#{email.id}}")
    accounts(:user).claim_core.instance_variable_set('@name_fact_emails', nil)
    assert_equal ['test@test.com'], accounts(:user).claim_core.emails
  end
end
