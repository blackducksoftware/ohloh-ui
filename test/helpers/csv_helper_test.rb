# frozen_string_literal: true

require 'test_helper'

class CsvHelperTest < ActionView::TestCase
  include CsvHelper

  describe 'csv_escape' do
    it 'should leave normal strings alone' do
      _(csv_escape('Hello World!')).must_equal 'Hello World!'
    end

    it 'should escape strings that contain commas' do
      _(csv_escape('Hello, World!')).must_equal '"Hello, World!"'
    end

    it 'should escape strings that contain single quotes' do
      _(csv_escape("World's Hello")).must_equal "\"World's Hello\""
    end

    it 'should escape strings that contain double quotes' do
      _(csv_escape('Hello "World!"')).must_equal '"Hello ""World!"""'
    end

    it 'should convert integers into strings' do
      _(csv_escape(4)).must_equal '4'
    end

    it 'should convert booleans into strings' do
      _(csv_escape(true)).must_equal 'true'
      _(csv_escape(false)).must_equal 'false'
    end
  end
end
