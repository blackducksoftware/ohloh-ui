# frozen_string_literal: true

require 'test_helper'

class NullObjectTest < ActiveSupport::TestCase
  let(:null_object) { NullObject.new }

  describe 'nil?' do
    it 'should return true' do
      _(null_object.nil?).must_equal true
    end
  end

  describe 'blank?' do
    it 'should return true' do
      _(null_object.blank?).must_equal true
    end
  end

  describe 'nought_methods' do
    it 'should create methods that return zero' do
      NullObject.nought_methods :test
      _(NullObject.new.test).must_equal 0
    end
  end

  describe 'blank_methods' do
    it 'must create methods that return blank value' do
      NullObject.blank_methods :test

      _(NullObject.new.test).must_be :blank?
    end
  end

  describe 'nil_methods' do
    it 'must create methods that return nil' do
      NullObject.nil_methods :test

      _(NullObject.new.test).must_be :nil?
    end
  end
end
