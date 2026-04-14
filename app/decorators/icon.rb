# frozen_string_literal: true

class Icon < Cherry::Decorator
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TagHelper

  IMAGE_SIZES = { med: 64, small: 32, tiny: 16 }.freeze
  FONT_SIZES = { 64 => 56, 48 => 40, 40 => 32, 32 => 26, 24 => 18, 16 => 13 }.freeze

  delegate :logo, :name, to: :object

  def image(with_dimensions: true, container_class: 'icon-container')
    has_attachment = logo&.attachment&.present?
    container_classes = "#{container_class} #{'has-logo' if has_attachment}"
    content = has_attachment ? logo_with_fallback(with_dimensions) : letter_only
    content_tag :div, content, class: container_classes
  end

  private

  def logo_with_fallback(with_dimensions)
    width_and_height = with_dimensions ? dimensions : ''
    css_style = "#{width_and_height} border:0 none;"
    img = image_tag(logo.attachment.url(size),
                    style: css_style,
                    itemprop: 'image',
                    alt: name,
                    onerror: "this.style.display='none'; this.nextElementSibling.style.display='flex';")
    letter = content_tag :span, name.first.upcase, class: 'icon-letter', style: 'display:none'
    img + letter
  end

  def letter_only
    content_tag :span, name.first.upcase, class: 'icon-letter'
  end

  def size
    @context[:size] || :small
  end

  def options
    @context[:options] || {}
  end

  def int_size
    options[:width] || options[:height] || IMAGE_SIZES[size]
  end

  def dimensions
    "width:#{int_size}px; height:#{int_size}px;"
  end

  def default_style
    font_size = FONT_SIZES[int_size] || 14
    opts = options.reverse_merge(bg: 'EEE', color: '000')
    margin_right = int_size == 64 ? 0 : 2

    "background-color:##{opts[:bg]}; color:##{opts[:color]}; border:1px dashed ##{opts[:color]};" \
      "font-size:#{font_size}px; line-height:#{int_size}px; #{dimensions}" \
      "text-align:center; float:left; margin-bottom:0; margin-top:3px; margin-right:#{margin_right}px"
  end
end
