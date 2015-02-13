require 'test_helper'

class BaseballCardTest < ActiveSupport::TestCase
  describe 'rows' do
    it 'should return all rows with their values' do
      org = create(:organization)
      best_vita = create(:best_vita)
      best_vita.account.update_attributes(best_vita_id: best_vita.id, created_at: Time.now - 4.days)
      Account::OrganizationCore.any_instance.stubs(:positions).returns([create(:position)])
      Account::OrganizationCore.any_instance.stubs(:orgs_for_my_positions).returns([org])
      Account::OrganizationCore.any_instance.stubs(:affiliations_for_my_positions).returns([org])

      result = [{ css: {}, label: 'First commit', value: '3 days ago' },
                { css: {}, label: 'Most recent commit', value: '1 day ago' },
                { css: {}, label: 'Has made', value: '0 commits' },
                { css: {}, label: 'Joined Open Hub', value: '4 days ago' },
                {
                  css: { style: 'min-height:38px;' },
                  label: I18n.t('accounts.show.baseball_card.contributed_to'),
                  partial: 'accounts/show/orgs',
                  locals: { orgs: [org] }
                },
                {
                  css: { style: 'min-height:38px;' },
                  label: I18n.t('accounts.show.baseball_card.contributed_for'),
                  partial: 'accounts/show/orgs',
                  locals: { orgs: [org] }
                }]
      BaseballCard.new(best_vita.account).rows.must_equal result
    end
  end
end
