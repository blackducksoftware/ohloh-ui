require 'test_helper'

class KudoTest < ActiveSupport::TestCase
  it 'recent' do
    Kudo.delete_all
    admin_account = create(:admin)
    create(:kudo, sender: accounts(:joe), account: admin_account)
    create(:kudo, sender: accounts(:user), account: admin_account)

    admin_account.kudos.count.must_equal 2
    admin_account.kudos.recent(1).length.must_equal 1
    admin_account.kudos.recent(1).first.sender_id.must_equal 3
  end

  describe 'sort_by_created_at' do
    before do
      Kudo.delete_all
      @admin_account = create(:admin)
      @kudo1 = create(:kudo, sender: @admin_account, account: accounts(:user),
                             project_id: 1)
      @kudo2 = create(:kudo, sender: @admin_account, account: nil,
                             project_id: 3)
      @kudo3 = create(:kudo, sender: @admin_account, account: accounts(:joe),
                             project_id: 2)
    end

    describe 'no account id' do
      before do
        Kudo.all.each { |kudo| kudo.update!(account_id: nil) }
      end

      it 'must order by created_at DESC' do
        @admin_account.sent_kudos.sort_by_created_at.must_equal [@kudo3, @kudo2, @kudo1]
      end

      it 'must order by project_id DESC when created_at is equal' do
        @kudo2.update!(created_at: @kudo3.created_at)

        @admin_account.sent_kudos.sort_by_created_at.must_equal [@kudo2, @kudo3, @kudo1]
      end
    end

    describe 'with or without account id' do
      it 'must work when some kudos have null account_id' do
        @admin_account.sent_kudos.sort_by_created_at.must_equal [@kudo3, @kudo2, @kudo1]
      end

      it 'must order by max created_at when kudos have same account_id' do
        @kudo1.update!(account_id: @kudo3.account_id)

        @admin_account.sent_kudos.sort_by_created_at.must_equal [@kudo3, @kudo1, @kudo2]
      end

      it 'must order by project_id when kudos have same account_id' do
        @kudo2.update!(project_id: 4, account: accounts(:joe))

        @admin_account.sent_kudos.sort_by_created_at.must_equal [@kudo2, @kudo3, @kudo1]
      end
    end
  end
end
