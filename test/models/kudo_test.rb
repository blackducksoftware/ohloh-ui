require 'test_helper'

class KudoTest < ActiveSupport::TestCase
  fixtures :accounts

  test 'recent' do
    Kudo.delete_all
    admin_account = accounts(:admin)
    create(:kudo, sender: accounts(:joe), account: admin_account)
    create(:kudo, sender: accounts(:user), account: admin_account)

    assert_equal 2, admin_account.kudos.count
    assert_equal 1, admin_account.kudos.recent(1).length
    assert_equal 3, admin_account.kudos.recent(1).first.sender_id
  end

  class SortByCreatedAt < KudoTest
    def setup
      Kudo.delete_all
      @admin_account = accounts(:admin)
      @kudo1 = create(:kudo, sender: @admin_account, account: accounts(:user),
                             project_id: 1)
      @kudo2 = create(:kudo, sender: @admin_account, account: nil,
                             project_id: 3)
      @kudo3 = create(:kudo, sender: @admin_account, account: accounts(:joe),
                             project_id: 2)
    end

    class NoAccountId < SortByCreatedAt
      def setup
        super
        Kudo.all.each { |kudo| kudo.update!(account_id: nil) }
      end

      test 'must order by created_at DESC' do
        assert_equal [@kudo3, @kudo2, @kudo1],
                     @admin_account.sent_kudos.sort_by_created_at
      end

      test 'must order by project_id DESC when created_at is equal' do
        @kudo2.update!(created_at: @kudo3.created_at)

        assert_equal [@kudo2, @kudo3, @kudo1],
                     @admin_account.sent_kudos.sort_by_created_at
      end
    end

    class WithOrWithoutAccountId < SortByCreatedAt
      test 'must work when some kudos have null account_id' do
        assert_equal [@kudo3, @kudo2, @kudo1],
                     @admin_account.sent_kudos.sort_by_created_at
      end

      test 'must order by max created_at when kudos have same account_id' do
        @kudo1.update!(account_id: @kudo3.account_id)

        assert_equal [@kudo3, @kudo1, @kudo2],
                     @admin_account.sent_kudos.sort_by_created_at
      end

      test 'must order by project_id when kudos have same account_id' do
        @kudo2.update!(project_id: 4, account: accounts(:joe))

        assert_equal [@kudo2, @kudo3, @kudo1],
                     @admin_account.sent_kudos.sort_by_created_at
      end
    end
  end
end
