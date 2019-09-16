# frozen_string_literal: true

require 'test_helper'

class StackWidgetTest < ActiveSupport::TestCase
  let(:stack) { create(:stack) }
  let(:widget) { StackWidget.new(stack_id: stack.id) }

  describe 'name' do
    it 'should return normal' do
      widget.name.must_equal 'normal'
    end
  end

  describe 'stack' do
    it 'should return the stack' do
      widget.stack.must_equal stack
    end
  end

  describe 'stack_entries' do
    it 'should return the stack' do
      widget.stack_entries.must_equal stack.stack_entries
    end
  end

  describe 'more' do
    it 'should return the diff between stack entries and projects_shown' do
      widget.more.must_equal stack.stack_entries.count - widget.projects_shown
    end
  end

  describe 'width' do
    it 'should return 114' do
      widget.stubs(:icon_height).returns(12)
      widget.width.must_equal 114
    end

    it 'should return 132' do
      widget.stubs(:icon_height).returns(16)
      widget.width.must_equal 130
    end
  end

  describe 'height' do
    it 'should return the height' do
      widget.height.must_equal 27
    end
  end

  describe 'position' do
    it 'should return 1' do
      widget.position.must_equal 1
    end
  end

  describe 'initialize' do
    it 'should show error when stack id is missing' do
      proc { StackWidget.new }.must_raise ArgumentError
    end
  end
end
