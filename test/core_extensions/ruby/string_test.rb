require 'test_helper'

class StringTest < ActiveSupport::TestCase
  test 'strip_tags' do
    assert_equal '', ''.strip_tags
    assert_equal 'test', 'test'.strip_tags
    assert_equal 'XY', 'X<br/>Y'.strip_tags
    assert_equal 'XY', '<p>X</p>Y'.strip_tags
    assert_equal 'X', '<p>X</p>'.strip_tags
    assert_equal 'XYZ', "X<a href='#'>Y</a>Z".strip_tags
    assert_equal 'XYZ', 'X<h1>Y</h2>Z'.strip_tags
    assert_equal 'X<Y', 'X<Y'.strip_tags
    assert_equal 'X>Y', 'X>Y'.strip_tags
    assert_equal 'X&gt;Y', 'X&gt;Y'.strip_tags
    assert_equal 'X&lt;Y', 'X&lt;Y'.strip_tags
    assert_equal 'X&amp;Y', 'X&amp;Y'.strip_tags
  end

  test 'strip_tags_preserve_line_breaks' do
    assert_equal '', ''.strip_tags_preserve_line_breaks
    assert_equal 'test', 'test'.strip_tags_preserve_line_breaks

    assert_equal '', "\n".strip_tags_preserve_line_breaks
    assert_equal 'X', "\nX".strip_tags_preserve_line_breaks
    assert_equal 'X', "X\n".strip_tags_preserve_line_breaks
    assert_equal 'X', "\n\nX\n\n".strip_tags_preserve_line_breaks

    assert_equal 'X<br/>Y', 'X<br/>Y'.strip_tags_preserve_line_breaks
    assert_equal 'X<br/>Y', "X\nY".strip_tags_preserve_line_breaks

    assert_equal 'X<br/><br/>Y', '<p>X</p>Y'.strip_tags_preserve_line_breaks
    assert_equal 'X', '<p>X</p>'.strip_tags_preserve_line_breaks

    assert_equal 'XYZ', "X<a href='#'>Y</a>Z".strip_tags_preserve_line_breaks
    assert_equal 'XYZ', 'X<h1>Y</h2>Z'.strip_tags_preserve_line_breaks
    assert_equal 'X<Y', 'X<Y'.strip_tags_preserve_line_breaks
    assert_equal 'X>Y', 'X>Y'.strip_tags_preserve_line_breaks

    assert_equal 'X>Y', 'X&gt;Y'.strip_tags_preserve_line_breaks
    assert_equal 'X<Y', 'X&lt;Y'.strip_tags_preserve_line_breaks
    assert_equal 'X&Y', 'X&amp;Y'.strip_tags_preserve_line_breaks
  end
end
