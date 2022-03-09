# frozen_string_literal: true

require 'test_helper'

class MarkdownHelperTest < ActionView::TestCase
  include MarkdownHelper

  describe 'markdown_format' do
    it 'should convert to markdown' do
      _(markdown_format('**wow**')).must_equal "<p><strong>wow</strong></p>\n"
    end

    it 'should just return the original string back if Redcarpet barfs' do
      Redcarpet::Markdown.any_instance.stubs(:render).raises(StandardError)
      _(markdown_format('**wow**')).must_equal '**wow**'
    end
  end
end
