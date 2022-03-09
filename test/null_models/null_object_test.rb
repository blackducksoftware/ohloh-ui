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
end
