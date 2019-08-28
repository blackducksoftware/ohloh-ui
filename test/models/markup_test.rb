# frozen_string_literal: true

require_relative '../test_helper'

class MarkupTest < ActiveSupport::TestCase
  it 'save cleanups up the raw html' do
    raw = "<script src='xss.js' />It was\nthe best of <b>cross</b> site scripts!"
    markup = Markup.create(raw: raw)
    markup.reload
    markup.raw.must_equal raw
    markup.formatted.must_equal 'It was<br/>the best of cross site scripts!'
  end

  it 'must validate the raw description' do
    markup = Markup.create(raw: Faker::Lorem.characters(600))
    markup.wont_be :valid?
    markup.errors.must_include :raw
    markup.errors.messages[:raw].must_equal ['is too long (maximum is 500 characters)']
  end

  it 'lines should return formatted value seperated by <br/>' do
    raw = "<script src='xss.js' />It was\nthe best of <b>cross</b> site scripts!"
    markup = Markup.create(raw: raw)
    markup.reload
    markup.formatted.must_equal 'It was<br/>the best of cross site scripts!'
    markup.lines.first.must_equal 'It was'
    markup.lines.last.must_equal 'the best of cross site scripts!'
  end

  it 'first_line should return first line of formatted value seperated by <br/>' do
    raw = "<script src='xss.js' />It was\nthe best of <b>cross</b> site scripts!"
    markup = Markup.create(raw: raw)
    markup.reload
    markup.formatted.must_equal 'It was<br/>the best of cross site scripts!'
    markup.first_line.must_equal 'It was'
  end
end
