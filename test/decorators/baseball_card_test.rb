# frozen_string_literal: true

require 'test_helper'

class BaseballCardTest < ActiveSupport::TestCase
  include ActionView::Helpers::DateHelper

  describe 'rows' do
    it 'should return all rows with their values' do
      org = create(:organization)
      best_account_analysis = create(:best_account_analysis)
      best_account_analysis.account.update(best_vita_id: best_account_analysis.id, created_at: 4.days.ago)
      create(:position, account: best_account_analysis.account)
      Account::OrganizationCore.any_instance.stubs(:positions).returns([create_position])
      Account::OrganizationCore.any_instance.stubs(:orgs_for_my_positions).returns([org])
      Account::OrganizationCore.any_instance.stubs(:affiliations_for_my_positions).returns([org])
      account_analysis_fact = best_account_analysis.account_analysis_fact
      account = best_account_analysis.account

      first_commit_day = I18n.t('accounts.show.baseball_card.duration',
                                date: distance_of_time_in_words_to_now(account_analysis_fact.first_checkin))
      last_commit_day = I18n.t('accounts.show.baseball_card.duration',
                               date: distance_of_time_in_words_to_now(account_analysis_fact.last_checkin))
      joined_day = I18n.t('accounts.show.baseball_card.duration',
                          date: distance_of_time_in_words_to_now(account.created_at))

      commits = I18n.t('accounts.show.baseball_card.commits.value', count: account_analysis_fact.commits)

      result = [{ css: {}, label: 'First commit', value: first_commit_day },
                { css: {}, label: 'Most recent commit', value: last_commit_day },
                { css: {}, label: 'Has made', value: commits },
                { css: {}, label: 'Joined Open Hub', value: joined_day },
                { css: {}, label: 'Contributed to',
                  value: "<a href=\"/accounts/#{account.login}/positions\">1 project</a>" },
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
      _(BaseballCard.new(best_account_analysis.account).rows).must_equal result
    end
  end
end
