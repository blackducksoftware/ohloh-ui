# frozen_string_literal: true

require 'test_helper'

class TinyTest < ActiveSupport::TestCase
  let(:account) { create(:account) }
  let(:widget) { Widget::AccountWidget::Tiny.new(account_id: account.id) }

  describe 'width' do
    it 'should return 80' do
      _(widget.width).must_equal 80
    end
  end

  describe 'height' do
    it 'should return 15' do
      _(widget.height).must_equal 15
    end
  end

  describe 'image' do
    it 'must call File.binread' do
      File.expects(:binread).once
      widget.image
    end
  end

  describe 'position' do
    it 'should return 3' do
      _(widget.position).must_equal 3
    end
  end
end
