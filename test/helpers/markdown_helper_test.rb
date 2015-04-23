require 'test_helper'

class MarkdownHelperTest < ActionView::TestCase
  include MarkdownHelper

  describe 'markdown_format' do
    it 'should convert to markdown' do
      markdown_format('**wow**').must_equal '<p><strong>wow</strong></p>'
    end

    it 'should just return the original string back if BlueCloth barfs' do
      BlueCloth.any_instance.stubs(:to_html).raises(StandardError)
      markdown_format('**wow**').must_equal '**wow**'
    end
  end
end
