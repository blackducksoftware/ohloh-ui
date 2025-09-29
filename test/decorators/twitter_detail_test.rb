# frozen_string_literal: true

require 'test_helper'

class TwitterDetailTest < ActiveSupport::TestCase
  let(:admin) { create(:admin) }
  let(:admin_twitter_detail) { TwitterDetail.new(admin) }
  let(:user) { create(:account_with_markup) }
  let(:user_twitter_detail) { TwitterDetail.new(user) }

  describe 'url' do
    it 'should return twitter url with given account' do
      url = 'https://twitter.com/intent/follow?original_referer=http%3A%2F%2Ftwiiter.com%2Fmighty_joe' \
            '&region=follow_link&screen_name=mighty_joe&source=followbutton&variant=2.0'

      admin.stubs(:twitter_account).returns('mighty_joe')
      _(admin_twitter_detail.url('http://twiiter.com/mighty_joe')).must_equal url
    end
  end

  describe 'twitter_card' do
    it 'should return empty string if markup is absent' do
      admin.stubs(:markup).returns(nil)
      _(admin_twitter_detail.description).must_equal ''
    end

    it 'should return markup if account_analysis_fact is absent' do
      _(user_twitter_detail.description).must_equal 'It was'
    end

    it 'should return full description if markup and account_analysis_fact is present' do
      language = create(:language)
      Account.any_instance.stubs(:most_experienced_language).returns(language)

      account_analysis = create(:account_analysis, account_id: user.id)
      user.update(best_account_analysis: account_analysis)
      create(:account_analysis_fact, vita_id: account_analysis.id)

      description = "It was, 0 total commits to 0 projects, most experienced in #{language.nice_name}, " \
                    'earned Kudo Rank'
      _(user_twitter_detail.description).must_equal description
    end
  end
end
