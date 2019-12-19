# frozen_string_literal: true

require 'test_helper'

class DetailedTest < ActiveSupport::TestCase
  let(:account) { create(:account) }
  let(:widget) { AccountWidget::Detailed.new(account_id: account.id) }

  describe 'width' do
    it 'should return 230' do
      widget.width.must_equal 230
    end
  end

  describe 'height' do
    it 'should return 35' do
      widget.height.must_equal 35
    end
  end

  describe 'position' do
    it 'should return 1' do
      widget.position.must_equal 1
    end
  end

  describe 'image' do
    it 'must call WidgetBadge::Account.create' do
      WidgetBadge::Account.expects(:create).once
      widget.image
    end
  end
end
