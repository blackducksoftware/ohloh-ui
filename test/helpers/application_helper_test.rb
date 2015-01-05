require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  it 'expander truncates strings on a word boundary' do
    text = expander('It was the best of times.', 5, 10)
    text.gsub(/\s/, '')[0..6].must_equal('It<span')
  end

  it 'expander truncates strings without leaving a dangling comma' do
    text = expander('It, or something like it, was the best of times.', 5, 10)
    text.gsub(/\s/, '')[0..6].must_equal('It<span')
  end
end
