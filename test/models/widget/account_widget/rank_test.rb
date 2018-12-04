require 'test_helper'

class RankTest < ActiveSupport::TestCase
  let(:account) { create(:account) }
  let(:widget) { AccountWidget::Rank.new(account_id: account.id) }

  describe 'width' do
    it 'should return 32' do
      widget.width.must_equal 32
    end
  end

  describe 'height' do
    it 'should return 24' do
      widget.height.must_equal 24
    end
  end

  describe 'image' do
    it 'must find the image using kudo_rank' do
      widget.account.stubs(:kudo_rank).returns(5)
      file_path = Rails.root.join('app', 'assets', 'images', 'icons', 'sm_laurel_5.png')
      File.expects(:binread).with(file_path).once
      widget.image
    end
  end

  describe 'position' do
    it 'should return 2' do
      widget.position.must_equal 2
    end
  end
end
