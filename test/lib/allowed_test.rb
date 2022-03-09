# frozen_string_literal: true

require 'test_helper'

class AllowedTest < ActiveSupport::TestCase
  describe 'parse' do
    it 'line empty' do
      _(Allowed.parse(nil)).must_be_empty
      _(Allowed.parse('')).must_be_empty
      _(Allowed.parse("\n")).must_be_empty
    end

    it 'should parse line Allow' do
      _(Allowed.parse('foo')).must_equal ['foo']
      _(Allowed.parse("foo\n")).must_equal ['foo']
      _(Allowed.parse("foo    \n")).must_equal ['foo']
      _(Allowed.parse("testfile.txt\n lib/")).must_equal ['testfile.txt', 'lib/']
    end

    it 'should allow with trailing wildcard' do
      _(Allowed.parse('foo*')).must_equal ['foo']
    end
  end

  describe 'match?' do
    it 'should return true if matched' do
      assert_not Allowed.match?([], nil)
      assert_not Allowed.match?([], 'foo')
      assert_not Allowed.match?(['bar'], 'foo')
      assert Allowed.match?(['foo'], 'foo')
      assert Allowed.match?(['foo'], 'foobar')
      assert_not Allowed.match?(['foobar'], 'foo')
      assert Allowed.match?(%w[bar foo], 'foo')
    end

    it 'should gracefully handle backslashes in the prefixes' do
      assert_not Allowed.match?(['\\c\\autoexec\\'], 'foo')
    end
  end
end
