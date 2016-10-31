require 'test_helper'

describe TravisBadge do
  let(:ent) { create(:enlistment) }
  let(:badge) { create(:travis_badge, project: ent.project, repository: ent.repository) }
  describe '#badge_url' do
    it 'should return full url of the travis badge source' do
      badge.badge_url.must_equal "#{ENV['TRAVIS_API_BASE_URL']}#{badge.identifier}"
    end
  end
end
