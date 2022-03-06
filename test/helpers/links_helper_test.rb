# frozen_string_literal: true

require 'test_helper'

class LinksHelperTest < ActionView::TestCase
  include LinksHelper

  it 'should slice host' do
    _(safe_slice_host('http://test.com/value')).must_equal 'test.com'
  end

  it 'should return host if url contains utf-8 encoding' do
    _(safe_slice_host('http://en.wikipedia.org/wiki/Étoilé')).must_equal 'en.wikipedia.org'
  end

  it 'should return utf-8 encoded host' do
    _(safe_slice_host('http://Étoilé.com/test')).must_equal '%C3%89toil%C3%A9.com'
  end
end
