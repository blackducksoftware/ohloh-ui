# frozen_string_literal: true

require 'test_helper'

class StringTest < ActiveSupport::TestCase
  it 'strip tags' do
    _(''.strip_tags).must_equal ''
    _('test'.strip_tags).must_equal 'test'
    _('X<br/>Y'.strip_tags).must_equal 'XY'
    _('<p>X</p>Y'.strip_tags).must_equal 'XY'
    _('<p>X</p>'.strip_tags).must_equal 'X'
    _("X<a href='#'>Y</a>Z".strip_tags).must_equal 'XYZ'
    _('X<h1>Y</h2>Z'.strip_tags).must_equal 'XYZ'
    _('X<Y'.strip_tags).must_equal 'X<Y'
    _('X>Y'.strip_tags).must_equal 'X>Y'
    _('X&gt;Y'.strip_tags).must_equal 'X&gt;Y'
    _('X&lt;Y'.strip_tags).must_equal 'X&lt;Y'
    _('X&amp;Y'.strip_tags).must_equal 'X&amp;Y'
  end

  it 'strip tags preserve line breaks' do
    _(''.strip_tags_preserve_line_breaks).must_equal ''
    _('test'.strip_tags_preserve_line_breaks).must_equal 'test'

    _("\n".strip_tags_preserve_line_breaks).must_equal ''
    _("\nX".strip_tags_preserve_line_breaks).must_equal 'X'
    _("X\n".strip_tags_preserve_line_breaks).must_equal 'X'
    _("\n\nX\n\n".strip_tags_preserve_line_breaks).must_equal 'X'

    _('X<br/>Y'.strip_tags_preserve_line_breaks).must_equal 'X<br/>Y'
    _("X\nY".strip_tags_preserve_line_breaks).must_equal 'X<br/>Y'

    _('<p>X</p>Y'.strip_tags_preserve_line_breaks).must_equal 'X<br/><br/>Y'
    _('<p>X</p>'.strip_tags_preserve_line_breaks).must_equal 'X'

    _("X<a href='#'>Y</a>Z".strip_tags_preserve_line_breaks).must_equal 'XYZ'
    _('X<h1>Y</h2>Z'.strip_tags_preserve_line_breaks).must_equal 'XYZ'
    _('X<Y'.strip_tags_preserve_line_breaks).must_equal 'X<Y'
    _('X>Y'.strip_tags_preserve_line_breaks).must_equal 'X>Y'

    _('X&gt;Y'.strip_tags_preserve_line_breaks).must_equal 'X>Y'
    _('X&lt;Y'.strip_tags_preserve_line_breaks).must_equal 'X<Y'
    _('X&amp;Y'.strip_tags_preserve_line_breaks).must_equal 'X&Y'
  end

  it 'clean up weirdly encoded strings' do
    before = "* oprava chyby 33731\n* \xFAprava  podle Revize B anglick\xE9ho dokumentu\n"
    after = ['* oprava chyby 33731', '* �prava  podle Revize B anglick�ho dokumentu']
    _(before.fix_encoding_if_invalid.split("\n")).must_equal after
  end

  it 'should not force_encode to utf-8 when string has valid encoding' do
    encoded_string = 'including \\xE2??fair'
    edit_id = create(:create_edit, value: encoded_string).id
    _(encoded_string.valid_encoding?).must_equal true
    _(encoded_string.encoding.to_s).must_equal 'UTF-8'
    edit = Edit.find(edit_id)
    _(edit.value.valid_encoding?).must_equal true
    _(edit.value.encoding.to_s).must_equal 'UTF-8'
    _(edit.value).must_equal encoded_string
  end

  it 'should not mangle good unicode strings' do
    _('Stefan Küng'.fix_encoding_if_invalid).must_equal 'Stefan Küng'
  end

  it 'should replace garbage encoded characters with unknowns' do
    bad_str = "\xE2??"
    _(bad_str.valid_encoding?).must_equal false
    bad_str = bad_str.fix_encoding_if_invalid
    _(bad_str.present?).must_equal true
    _(bad_str.valid_encoding?).must_equal true
    _(bad_str).must_equal '�??'
  end

  it 'valid_http_url? returns true for http:// urls' do
    _('http://cnn.com/sports'.valid_http_url?).must_equal true
  end

  it 'valid_http_url? returns true for https:// urls' do
    _('https://cnn.com/sports'.valid_http_url?).must_equal true
  end

  it 'valid_http_url? returns false for string that start with urls, but then are other things' do
    _('http://apt227.com is the place to be; with Martha Gibbs and her family!'.valid_http_url?).must_equal false
  end

  it 'valid_http_url? returns false for ftp:// urls' do
    _('ftp://cnn.com/sports'.valid_http_url?).must_equal false
  end

  it 'valid_http_url? returns false for random string' do
    _('I am a banana!'.valid_http_url?).must_equal false
  end

  it 'clean_url does nothing to nils' do
    _(String.clean_url(nil)).must_be_nil
  end

  it 'clean_url strips whitespace' do
    _(String.clean_url(" \r\n\t http://cnn.com \r\n\t ")).must_equal 'http://cnn.com'
  end

  it 'clean_url prepends http:// if needed' do
    _(String.clean_url('cnn.com/sports')).must_equal 'http://cnn.com/sports'
  end

  it 'clean_url just returns back a valid http:// url' do
    _(String.clean_url('http://cnn.com/sports')).must_equal 'http://cnn.com/sports'
  end

  it 'clean_url just returns back a valid https:// url' do
    _(String.clean_url('https://cnn.com/sports')).must_equal 'https://cnn.com/sports'
  end

  it 'clean_url just returns back a valid ftp:// url' do
    _(String.clean_url('ftp://cnn.com/sports')).must_equal 'ftp://cnn.com/sports'
  end

  describe 'to_bool' do
    it 'truthy values are true' do
      _('t'.to_bool).must_equal true
      _('true'.to_bool).must_equal true
      _('y'.to_bool).must_equal true
      _('yes'.to_bool).must_equal true
      _('1'.to_bool).must_equal true
    end

    it 'falsey values are false' do
      _('f'.to_bool).must_equal false
      _('false'.to_bool).must_equal false
      _('n'.to_bool).must_equal false
      _('no'.to_bool).must_equal false
      _('0'.to_bool).must_equal false
    end
  end
end
