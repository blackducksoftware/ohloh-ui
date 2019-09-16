# frozen_string_literal: true

# The width is constrained to be about 22 characters, so its up to the caller
# to shorten each string to the correct length (or add ellipses).
module WidgetBadge
  module Partner
    module_function

    include BadgeHelper

    DEFAULT_FONT_OPTIONS = { font_size: 14, blur: 0, opacity: 80, stroke: '#0099ff', weight: 350,
                             align: :center, y_offset: 0 }.freeze

    def create(image_data)
      GC.start

      tempfile = Tempfile.new(['partner-badge', '.gif'])
      animate(*image_data, tempfile.path)
      image = MiniMagick::Image.open(tempfile.path)
      tempfile.close
      image.to_blob
    end

    def new_text_image(text, options)
      new_image do |convert|
        convert.size('150x26')
        convert << 'xc:white'

        set_font_and_color(convert, options)
        set_gravity(convert, options[:align])

        convert.motion_blur("0.0x#{options[:blur]}+90") if options[:blur] != 0
        convert.draw "text 0,#{3 + options[:y_offset]} '#{text}'"
      end
    end

    def add_text(text, options = {})
      merged_options = DEFAULT_FONT_OPTIONS.merge(options)

      image = setup_blank
      return image if text.blank?

      image.composite(new_text_image(text, merged_options)) do |img|
        img.geometry '+80+5'
      end
    end

    def animate(*image_data, file_path)
      MiniMagick::Tool::Convert.new do |convert|
        image_data.each do |options|
          convert_with_delay(convert, 320, options.merge(opacity: 100))
          convert_with_delay(convert, 10, options.merge(opacity: 70))
          convert_with_delay(convert, 10, options.merge(opacity: 20))
          convert_with_delay(convert, 20, options.merge(opacity: 0))
        end
        convert << file_path
      end
    end

    private_class_method :add_text, :new_text_image, :animate
  end
end
