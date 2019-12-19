# frozen_string_literal: true

require 'test_helper'

class IgnoreTest < ActiveSupport::TestCase
  describe 'parse' do
    it 'line empty' do
      Ignore.parse(nil).must_be_empty
      Ignore.parse('').must_be_empty
      Ignore.parse("  \n").must_be_empty
    end

    it 'should parse line Disallow' do
      Ignore.parse('Disallow: /foo').must_equal ['/foo']
      Ignore.parse('Disallow:/foo').must_equal ['/foo']
      Ignore.parse('disallow: /foo').must_equal ['/foo']
      Ignore.parse("Disallow: /foo\n").must_equal ['/foo']
      Ignore.parse("Disallow: /foo /bar /baz\n").must_equal ['/foo']
      Ignore.parse("    Disallow:   /foo    \n").must_equal ['/foo']
      Ignore.parse('Allow: /foo').must_be_empty
      Ignore.parse('Garbage Disallow: /foo').must_be_empty
      Ignore.parse("Disallow: testfile.txt\nDisallow: lib/").must_equal ['testfile.txt', 'lib/']
    end

    it 'should allow everything' do
      Ignore.parse('Disallow: ').must_be_empty
      Ignore.parse('Disallow:').must_be_empty
      Ignore.parse('Disallow:/').must_be_empty
      Ignore.parse('Disallow: /').must_be_empty
      Ignore.parse('Disallow:*').must_be_empty
      Ignore.parse('Disallow: *').must_be_empty
    end

    it 'should recognise comments' do
      Ignore.parse('Disallow: /foo # comment').must_equal ['/foo']
      Ignore.parse('Disallow: /foo #comment').must_equal ['/foo']
      Ignore.parse('Disallow: /foo#comment').must_equal ['/foo#comment']
      Ignore.parse('# Disallow: /foo').must_be_empty
      Ignore.parse('#Disallow: /foo').must_be_empty
      Ignore.parse('Disallow: #/foo').must_be_empty
      Ignore.parse('Disallow:#/foo').must_be_empty
    end

    it 'should disallow with trailing wildcard' do
      Ignore.parse('Disallow: /foo*').must_equal ['/foo']
    end

    it 'should disallow with internal wildcard' do
      Ignore.parse('Disallow: /foo/*/bar').must_be_empty
      Ignore.parse('Disallow: *.xml').must_be_empty
    end

    it 'should parse empty string' do
      Ignore.parse(nil).must_be_empty
      Ignore.parse('').must_be_empty
      Ignore.parse("  \n\n  \n  ").must_be_empty
    end
  end

  describe 'match?' do
    it 'should return true if matched' do
      assert_not Ignore.match?([], nil)
      assert_not Ignore.match?([], 'foo')
      assert_not Ignore.match?(['bar'], 'foo')
      assert Ignore.match?(['foo'], 'foo')
      assert Ignore.match?(['foo'], 'foobar')
      assert_not Ignore.match?(['foobar'], 'foo')
      assert Ignore.match?(%w[bar foo], 'foo')
    end

    it 'should gracefully handle backslashes in the prefixes' do
      assert_not Ignore.match?(['\\c\\autoexec\\'], 'foo')
    end
  end
end
