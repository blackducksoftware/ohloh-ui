# frozen_string_literal: true

require 'test_helper'

describe TravisBadge do
  let(:badge) { create(:travis_badge, enlistment: create(:enlistment)) }

  describe '#badge_url' do
    it 'should return full url of the travis badge source' do
      _(badge.badge_url).must_equal "#{ENV.fetch('TRAVIS_API_BASE_URL', nil)}#{badge.identifier}"
    end
  end
end
