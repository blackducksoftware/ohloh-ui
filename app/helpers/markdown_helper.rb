module MarkdownHelper
  def markdown_format(markdown)
    BlueCloth.new(markdown.to_s).to_html
  rescue
    Rails.logger.error "BlueCloth failed to convert:\n#{markdown}."
    markdown.to_s
  end
end
