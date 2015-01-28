require 'test_helper'
class BadgeDecoratorTest < Draper::TestCase
  describe 'KudoRankBadge' do
    before do
      Draper::ViewContext.clear!
    end

    let(:account) { create(:account) }
    let(:kudo_badge) { BadgeDecorator.new(KudoRankBadge.new(account)) }

    it 'should do return the image URL' do
      kudo_badge.image_url.wont_be_empty
      kudo_badge.image_url.must_equal 'http://test.host/images/badges/kudo_rank.png'
    end

    it 'should do return the css_class' do
      kudo_badge.css_class(1, 'small', 4).wont_be_empty
      kudo_badge.css_class(1, 'small', 4).must_equal 'kudo-rank-badge'
    end

    it 'should return the pips url' do
      kudo_badge.pips_url.wont_be_empty
      kudo_badge.pips_url.must_equal 'http://test.host/images/badges/pips_01.png'
    end
  end
end
