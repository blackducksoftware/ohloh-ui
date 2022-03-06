# frozen_string_literal: true

require 'test_helper'

class StackWidgetTest < ActiveSupport::TestCase
  let(:stack) { create(:stack) }
  let(:widget) { StackWidget.new(stack_id: stack.id) }

  describe 'name' do
    it 'should return normal' do
      _(widget.name).must_equal 'normal'
    end
  end

  describe 'stack' do
    it 'should return the stack' do
      _(widget.stack).must_equal stack
    end
  end

  describe 'stack_entries' do
    it 'should return the stack' do
      _(widget.stack_entries).must_equal stack.stack_entries
    end
  end

  describe 'more' do
    it 'should return the diff between stack entries and projects_shown' do
      _(widget.more).must_equal stack.stack_entries.count - widget.projects_shown
    end
  end

  describe 'width' do
    it 'should return 114' do
      widget.stubs(:icon_height).returns(12)
      _(widget.width).must_equal 114
    end

    it 'should return 132' do
      widget.stubs(:icon_height).returns(16)
      _(widget.width).must_equal 130
    end
  end

  describe 'height' do
    it 'should return the height' do
      _(widget.height).must_equal 27
    end
  end

  describe 'position' do
    it 'should return 1' do
      _(widget.position).must_equal 1
    end
  end

  describe 'initialize' do
    it 'should show error when stack id is missing' do
      _(proc { StackWidget.new }).must_raise ArgumentError
    end
  end
end
