# frozen_string_literal: true

require 'test_helper'

class NilPositionTest < ActiveSupport::TestCase
  let(:nil_position) { NilPosition.new }

  describe 'title' do
    it 'should return nil' do
      assert_nil nil_position.title
    end
  end

  describe 'active?' do
    it 'should return false' do
      nil_position.active?.must_equal false
    end
  end

  describe 'nil?' do
    it 'should return true' do
      nil_position.nil?.must_equal true
    end
  end

  describe 'blank?' do
    it 'should return true' do
      nil_position.blank?.must_equal true
    end
  end

  describe 'present?' do
    it 'should be false' do
      nil_position.present?.must_equal false
    end
  end
end
