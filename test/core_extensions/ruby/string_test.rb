# encoding: utf-8
require 'test_helper'

class StringTest < ActiveSupport::TestCase
  it 'strip tags' do
    ''.strip_tags.must_equal ''
    'test'.strip_tags.must_equal 'test'
    'X<br/>Y'.strip_tags.must_equal 'XY'
    '<p>X</p>Y'.strip_tags.must_equal 'XY'
    '<p>X</p>'.strip_tags.must_equal 'X'
    "X<a href='#'>Y</a>Z".strip_tags.must_equal 'XYZ'
    'X<h1>Y</h2>Z'.strip_tags.must_equal 'XYZ'
    'X<Y'.strip_tags.must_equal 'X<Y'
    'X>Y'.strip_tags.must_equal 'X>Y'
    'X&gt;Y'.strip_tags.must_equal 'X&gt;Y'
    'X&lt;Y'.strip_tags.must_equal 'X&lt;Y'
    'X&amp;Y'.strip_tags.must_equal 'X&amp;Y'
  end

  it 'strip tags preserve line breaks' do
    ''.strip_tags_preserve_line_breaks.must_equal ''
    'test'.strip_tags_preserve_line_breaks.must_equal 'test'

    "\n".strip_tags_preserve_line_breaks.must_equal ''
    "\nX".strip_tags_preserve_line_breaks.must_equal 'X'
    "X\n".strip_tags_preserve_line_breaks.must_equal 'X'
    "\n\nX\n\n".strip_tags_preserve_line_breaks.must_equal 'X'

    'X<br/>Y'.strip_tags_preserve_line_breaks.must_equal 'X<br/>Y'
    "X\nY".strip_tags_preserve_line_breaks.must_equal 'X<br/>Y'

    '<p>X</p>Y'.strip_tags_preserve_line_breaks.must_equal 'X<br/><br/>Y'
    '<p>X</p>'.strip_tags_preserve_line_breaks.must_equal 'X'

    "X<a href='#'>Y</a>Z".strip_tags_preserve_line_breaks.must_equal 'XYZ'
    'X<h1>Y</h2>Z'.strip_tags_preserve_line_breaks.must_equal 'XYZ'
    'X<Y'.strip_tags_preserve_line_breaks.must_equal 'X<Y'
    'X>Y'.strip_tags_preserve_line_breaks.must_equal 'X>Y'

    'X&gt;Y'.strip_tags_preserve_line_breaks.must_equal 'X>Y'
    'X&lt;Y'.strip_tags_preserve_line_breaks.must_equal 'X<Y'
    'X&amp;Y'.strip_tags_preserve_line_breaks.must_equal 'X&Y'
  end

  it 'clean up weirdly encoded strings' do
    before = "* oprava chyby 33731\n* \xFAprava  podle Revize B anglick\xE9ho dokumentu\n"
    after = ['* oprava chyby 33731', '* �prava  podle Revize B anglick�ho dokumentu']
    before.fix_encoding_if_invalid!.split("\n").must_equal after
  end
end
