class Icon < Draper::Decorator
  IMAGE_SIZES = { med: 64, small: 32, tiny: 16 }
  FONT_SIZES = { 64 => 56, 48 => 40, 40 => 32, 32 => 26, 24 => 18, 16 => 13 }

  delegate_all

  def initialize(*args)
    super
    @size = @context[:size] || :small
    @opts = @context[:opts] || {}
  end

  def image
    if logo
      h.image_tag(logo.attachment.url(@size), style: "#{dimensions} border:0 none;", itemprop: 'image', alt: name)
    else
      h.haml_tag :p, name.first.capitalize, style: default_style
    end
  end

  private

  def int_size
    @opts[:width] || @opts[:height] || IMAGE_SIZES[@size]
  end

  def dimensions
    "width:#{int_size}px; height:#{int_size}px;"
  end

  def default_style
    fnt_size = FONT_SIZES[int_size] || 14
    @opts.reverse_merge!(bg: 'EEE', color: '000')
    margin_right = int_size == 64 ? 0 : 2

    "background-color:##{@opts[:bg]}; color:##{@opts[:color]}; border:1px dashed ##{@opts[:color]};"\
    "font-size:#{fnt_size}px; line-height:#{int_size}px; #{dimensions}"\
    "text-align:center; float:left; margin-bottom:0; margin-top:0; margin-right:#{margin_right}px"
  end
end
