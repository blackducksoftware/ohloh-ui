require_relative '../test_helper'

class MarkupTest < ActiveSupport::TestCase
  it 'save cleanups up the raw html' do
    raw = "<script src='xss.js' />It was\nthe best of <b>cross</b> site scripts!"
    markup = Markup.create(raw: raw)
    markup.reload
    markup.raw.must_equal raw
    markup.formatted.must_equal 'It was<br/>the best of cross site scripts!'
  end

  test 'it should validate the raw description' do
    markup = Markup.create(raw: Faker::Lorem.characters(600))
    assert_not markup.valid?
    assert_includes markup.errors, :raw
    assert_equal ['is too long (maximum is 500 characters)'], markup.errors.messages[:raw]
  end
end
