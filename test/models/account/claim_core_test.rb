require 'test_helper'

class ClaimCoreTest < ActiveSupport::TestCase
  let(:project) { create(:project, best_analysis: create(:analysis)) }
  let(:project2) { create(:project, best_analysis: create(:analysis)) }
  let(:project2_commit) do
    create(:commit, code_set: create(:code_set))
  end
  let(:account) do
    account = create(:account)
    account.person.update(name_fact: create(:name_fact))
    account
  end
  let(:unactivated_account) { create(:unactivated) }
  let(:position) { create_position(account: account, project: project) }
  let(:position_name) { position.name }
  let(:email1) { create(:email_address, address: 'test1@test.com') }
  let(:email2) { create(:email_address, address: 'test2@test.com') }

  describe 'email_ids' do
    it 'should return empty for accounts with no email in name_facts' do
      account.claim_core.email_ids.must_be_empty
      unactivated_account.claim_core.emails.must_be_empty
    end

    it 'should return emails when account name_facts have emails ids' do
      position.name_fact.update_attribute(:email_address_ids, "{#{email1.id}}")
      account.claim_core.email_ids.must_equal [email1.id]
    end

    it 'should return email ids after claiming a position on a new project' do
      project2_commit.update_attribute(:email_address_id, email2.id)
      position = create_position(account: account, project: project2)

      position.name_fact.update!(email_address_ids: "{#{email2.id}}", name_id: position_name.id)
      (account.claim_core.email_ids - [email1.id, email2.id]).must_be_empty
    end

    it 'should return email id when claimed position has a new name' do
      new_name = setup_new_name_with_facts(email2)

      position.update!(name: new_name)
      account.claim_core.email_ids.must_equal [email2.id]
    end

    it 'should return email ids when alias has an email' do
      set_aliases(email1)
      account.claim_core.email_ids.must_equal [email1.id]
    end

    it 'should return empty [] when aliased preferred_name name_facts has no emails' do
      alias_object = set_aliases(email1)
      account.claim_core.email_ids.must_equal [email1.id]

      alias_object.update!(preferred_name_id: create(:name).id)
      account.claim_core.email_ids.must_be_empty
    end

    it 'should return [] when alias is removed' do
      alias_object = set_aliases(email2)
      account.claim_core.email_ids.must_equal [email2.id]

      alias_object.create_edit.undo!(account)
      account.claim_core.email_ids.must_be_empty
    end

    it 'should return multiple ids when present' do
      set_aliases(email1)
      position.name_fact.update_attribute(:email_address_ids, "{#{email2.id}}")
      ([email1.id, email2.id] - account.claim_core.email_ids).must_be_empty
    end

    it 'should return single id when multiple emails present are the same' do
      set_aliases(email1)
      position.name_fact.update_attribute(:email_address_ids, "{#{email1.id}}")
      account.claim_core.email_ids.must_equal [email1.id]
    end

    it 'should return empty [] when project is deleted' do
      position.name_fact.update_attribute(:email_address_ids, "{#{email1.id}}")
      account.claim_core.email_ids.must_equal [email1.id]

      position.project.update!(deleted: true, editor_account: account)
      account.claim_core.email_ids.must_be_empty
    end
  end

  describe 'claimed_emails' do
    it 'should return empty []' do
      account.claim_core.emails.must_be_empty
      unactivated_account.claim_core.emails.must_be_empty
    end

    it 'should return emails' do
      position.name_fact.update_attribute(:email_address_ids, "{#{email1.id}}")
      account.claim_core.emails.must_equal ['test1@test.com']
    end
  end

  describe 'unclaimed_persons_count' do
    before { create(:person, name_fact: position.name_fact) }

    it 'should return zero' do
      account.claim_core.unclaimed_persons_count.must_equal 0
    end

    it 'should return unclaimed persons count' do
      position.name_fact.update_attribute(:email_address_ids, "{#{email1.id}}")
      account.claim_core.unclaimed_persons_count.must_equal 1
    end
  end

  private

  def setup_new_name_with_facts(email)
    new_name = create(:name)
    create(:name_fact, name: new_name, email_address_ids: "{#{email.id}}", analysis: project.best_analysis)
    new_name
  end

  def set_aliases(email)
    Project.any_instance.stubs(:code_locations).returns([])
    new_name = setup_new_name_with_facts(email)
    create(:alias, commit_name_id: new_name.id, preferred_name_id: position_name.id, project_id: project.id)
  end
end
