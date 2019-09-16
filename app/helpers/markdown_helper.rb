# frozen_string_literal: true

module MarkdownHelper
  def markdown_format(text)
    options = { filter_html: true,
                hard_wrap: true,
                link_attributes: { rel: 'nofollow', target: '_blank' } }
    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, autolink: true, tables: true)
    markdown.render(text).html_safe
  rescue StandardError
    Rails.logger.error "Redcarpet failed to convert:\n#{text}."
    text.to_s
  end
end
