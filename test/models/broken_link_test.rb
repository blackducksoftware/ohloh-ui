require 'test_helper'

class BrokenLinkTest < ActiveSupport::TestCase
  let(:broken_link) { create(:broken_link) }
  let(:broken_link_with_redirection) { create(:broken_link, error: '301: Net::HTTPMovedPermanently') }

  before do
    broken_link
  end

  describe '.filter_by' do
    it 'filter_by with nil string' do
      BrokenLink.filter_by(nil).count.must_equal BrokenLink.count
    end

    it 'filter_by with error type' do
      BrokenLink.filter_by('301: Net::HTTPMovedPermanently').must_equal [broken_link_with_redirection]
    end
  end
end
