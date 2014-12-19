require_relative '../test_helper'

class MarkupTest < ActiveSupport::TestCase
  test 'save cleanups up the raw html' do
    raw = "<script src='xss.js' />It was\nthe best of <b>cross</b> site scripts!"
    markup = Markup.create(raw: raw)
    markup.reload
    assert_equal raw, markup.raw
    assert_equal 'It was<br/>the best of cross site scripts!', markup.formatted
  end

  test 'it should validate the raw description' do
    markup = Markup.create(raw: Faker::Lorem.characters(600))
    assert_not account.valid?
    assert_includes markup.errors, :raw
    assert_equal ['is too long (maximum is 500 characters)'], markup.errors.messages[:raw]
  end
end
