# frozen_string_literal: true

require 'test_helper'

class KudoTest < ActiveSupport::TestCase
  let(:admin_account) { create(:admin) }
  let(:user1_account) { create(:account) }
  let(:user2_account) { create(:account) }
  let(:project1) { create(:project) }
  let(:project2) { create(:project) }
  let(:project3) { create(:project) }

  it 'recent' do
    Kudo.delete_all
    create(:kudo, sender: user1_account, account: admin_account)
    create(:kudo, sender: user2_account, account: admin_account)

    _(admin_account.kudos.count).must_equal 2
    _(admin_account.kudos.recent(1).length).must_equal 1
    _(admin_account.kudos.recent(1).first.sender_id).must_equal user1_account.id
  end

  it 'prevents kudoing oneself' do
    account = create(:account)
    _(proc { create(:kudo, sender: account, account: account) }).must_raise ActiveRecord::RecordInvalid
  end

  describe 'sort_by_created_at' do
    before do
      Kudo.delete_all
      @kudo1 = create(:kudo, sender: admin_account, account: user1_account,
                             project_id: project1.id)
      @kudo2 = create(:kudo, sender: admin_account, account: nil,
                             project_id: project2.id)
      @kudo3 = create(:kudo, sender: admin_account, account: user2_account,
                             project_id: project3.id)
    end

    describe 'no account id' do
      before do
        Kudo.find_each { |kudo| kudo.update!(account_id: nil) }
      end

      it 'must order by created_at DESC' do
        _(admin_account.sent_kudos.sort_by_created_at).must_equal [@kudo3, @kudo2, @kudo1]
      end

      it 'must order by project_id DESC when created_at is equal' do
        @kudo2.update!(created_at: @kudo3.created_at, project_id: create(:project).id)

        _(admin_account.sent_kudos.sort_by_created_at).must_equal [@kudo2, @kudo3, @kudo1]
      end
    end

    describe 'with or without account id' do
      it 'must work when some kudos have null account_id' do
        _(admin_account.sent_kudos.sort_by_created_at).must_equal [@kudo3, @kudo2, @kudo1]
      end

      it 'must order by max created_at when kudos have same account_id' do
        @kudo1.update!(account_id: @kudo3.account_id)

        _(admin_account.sent_kudos.sort_by_created_at).must_equal [@kudo3, @kudo1, @kudo2]
      end

      it 'must order by project_id when kudos have same account_id' do
        @kudo2.update!(project_id: create(:project).id, account: user2_account)

        _(admin_account.sent_kudos.sort_by_created_at).must_equal [@kudo2, @kudo3, @kudo1]
      end
    end
  end

  describe '#person' do
    it 'must find users by account preferably' do
      kudo = create(:kudo)
      _(kudo.person.account_id).must_equal kudo.account_id
    end

    it 'must find users by name and project if there is no account_id' do
      kudo = create(:kudo_with_name, account: nil)
      _(kudo.person.id).wont_equal nil
    end
  end

  describe '#person_name' do
    it 'must find users by account preferably' do
      kudo = create(:kudo)
      _(kudo.person_name).must_equal kudo.account.name
    end

    it 'must find users by name if there is no account_id' do
      kudo = create(:kudo_with_name, account: nil)
      _(kudo.person_name).must_equal kudo.name.name
    end
  end

  describe '#find_for_sender_and_target' do
    it 'must find users by account' do
      kudo = create(:kudo)
      found_kudo = Kudo.find_for_sender_and_target(kudo.sender, kudo.account)
      _(kudo.id).must_equal found_kudo.id
    end

    it 'must find users by person' do
      kudo = create(:kudo_with_name, account: nil)
      found_kudo = Kudo.find_for_sender_and_target(kudo.sender, kudo.person)
      _(kudo.id).must_equal found_kudo.id
    end

    it 'must error if the target is not a supported data type' do
      _(proc { Kudo.find_for_sender_and_target(create(:kudo).sender, 'hello') }).must_raise RuntimeError
    end
  end
end
