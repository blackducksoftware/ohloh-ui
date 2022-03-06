# frozen_string_literal: true

require 'test_helper'

class WidgetTest < ActiveSupport::TestCase
  let(:account) { create(:account) }
  let(:widget) { Widget.new(account_id: account.id, style: 'test') }

  describe 'title' do
    it 'should return the title' do
      _(widget.title).must_equal I18n.t('widgets.title')
    end
  end

  describe 'description' do
    it 'should return the description' do
      _(widget.description).must_equal I18n.t('widgets.description')
    end
  end

  describe 'nice_name' do
    it 'should return the nice_name' do
      _(widget.nice_name).must_equal 'Widget'
    end
  end

  describe 'short_nice_name' do
    it 'should return the short_nice_name' do
      _(widget.short_nice_name).must_equal 'Widget'
    end
  end

  describe 'name' do
    it 'should return the name' do
      _(widget.name).must_equal 'Widget'
    end
  end

  describe 'height' do
    it 'should return the height' do
      _(widget.height).must_equal 0
    end
  end

  describe 'width' do
    it 'should return the width' do
      _(widget.width).must_equal 0
    end
  end

  describe 'can_display' do
    it 'should return true' do
      _(widget.can_display?).must_equal true
    end
  end

  describe 'method_missing' do
    it 'should return value passed on initialize' do
      _(widget.style).must_equal 'test'
    end

    it 'should throw NoMethodError exception when it mismatches value passed on initialize' do
      _(-> { widget.not_a_method }).must_raise NoMethodError
    end
  end
end
