# frozen_string_literal: true

require 'test_helper'

class NilPositionTest < ActiveSupport::TestCase
  let(:nil_position) { NilPosition.new }

  describe 'title' do
    it 'should return nil' do
      _(nil_position.title).must_be_nil
    end
  end

  describe 'active?' do
    it 'should return false' do
      _(nil_position.active?).must_equal false
    end
  end

  describe 'nil?' do
    it 'should return true' do
      _(nil_position.nil?).must_equal true
    end
  end

  describe 'blank?' do
    it 'should return true' do
      _(nil_position.blank?).must_equal true
    end
  end

  describe 'present?' do
    it 'should be false' do
      _(nil_position.present?).must_equal false
    end
  end
end
