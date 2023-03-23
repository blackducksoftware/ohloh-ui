# frozen_string_literal: true

module MarkdownHelper
  def markdown_format(text)
    options = { filter_html: true, hard_wrap: true, link_attributes: { rel: 'nofollow', target: '_blank' } }
    renderer = Redcarpet::Render::HTML.new(options)
    extensions = { autolink: true, tables: true, quote: true, highlight: true, strikethrough: true, lax_spacing: true,
                   fenced_code_blocks: true, disable_indented_code_blocks: true, space_after_headers: true }
    markdown = Redcarpet::Markdown.new(renderer, extensions)
    markdown.render(text).html_safe
  rescue StandardError
    Rails.logger.error "Redcarpet failed to convert:\n#{text}."
    text.to_s
  end
end
