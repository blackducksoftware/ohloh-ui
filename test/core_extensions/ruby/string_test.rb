# frozen_string_literal: true

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
    before.fix_encoding_if_invalid.split("\n").must_equal after
  end

  it 'should not force_encode to utf-8 when string has valid encoding' do
    encoded_string = 'including \\xE2??fair'
    edit_id = create(:create_edit, value: encoded_string).id
    encoded_string.valid_encoding?.must_equal true
    encoded_string.encoding.to_s.must_equal 'UTF-8'
    edit = Edit.find(edit_id)
    edit.value.valid_encoding?.must_equal true
    edit.value.encoding.to_s.must_equal 'UTF-8'
    edit.value.must_equal encoded_string
  end

  it 'should not mangle good unicode strings' do
    'Stefan Küng'.fix_encoding_if_invalid.must_equal 'Stefan Küng'
  end

  it 'should replace garbage encoded characters with unknowns' do
    bad_str = "\xE2??"
    bad_str.valid_encoding?.must_equal false
    bad_str = bad_str.fix_encoding_if_invalid
    bad_str.present?.must_equal true
    bad_str.valid_encoding?.must_equal true
    bad_str.must_equal '�??'
  end

  it 'valid_http_url? returns true for http:// urls' do
    'http://cnn.com/sports'.valid_http_url?.must_equal true
  end

  it 'valid_http_url? returns true for https:// urls' do
    'https://cnn.com/sports'.valid_http_url?.must_equal true
  end

  it 'valid_http_url? returns false for string that start with urls, but then are other things' do
    'http://apt227.com is the place to be; with Martha Gibbs and her family!'.valid_http_url?.must_equal false
  end

  it 'valid_http_url? returns false for ftp:// urls' do
    'ftp://cnn.com/sports'.valid_http_url?.must_equal false
  end

  it 'valid_http_url? returns false for random string' do
    'I am a banana!'.valid_http_url?.must_equal false
  end

  it 'clean_url does nothing to nils' do
    assert_nil String.clean_url(nil)
  end

  it 'clean_url strips whitespace' do
    String.clean_url(" \r\n\t http://cnn.com \r\n\t ").must_equal 'http://cnn.com'
  end

  it 'clean_url prepends http:// if needed' do
    String.clean_url('cnn.com/sports').must_equal 'http://cnn.com/sports'
  end

  it 'clean_url just returns back a valid http:// url' do
    String.clean_url('http://cnn.com/sports').must_equal 'http://cnn.com/sports'
  end

  it 'clean_url just returns back a valid https:// url' do
    String.clean_url('https://cnn.com/sports').must_equal 'https://cnn.com/sports'
  end

  it 'clean_url just returns back a valid ftp:// url' do
    String.clean_url('ftp://cnn.com/sports').must_equal 'ftp://cnn.com/sports'
  end

  describe 'to_bool' do
    it 'truthy values are true' do
      't'.to_bool.must_equal true
      'true'.to_bool.must_equal true
      'y'.to_bool.must_equal true
      'yes'.to_bool.must_equal true
      '1'.to_bool.must_equal true
    end

    it 'falsey values are false' do
      'f'.to_bool.must_equal false
      'false'.to_bool.must_equal false
      'n'.to_bool.must_equal false
      'no'.to_bool.must_equal false
      '0'.to_bool.must_equal false
    end
  end
end
