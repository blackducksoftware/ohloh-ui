# frozen_string_literal: true

# The width is constrained to be about 22 characters, so its up to the caller
# to shorten each string to the correct length (or add ellipses).

module WidgetBadge
  module Thin
    module_function

    include BadgeHelper

    def create(image_data)
      GC.start

      tempfile = Tempfile.new(['thin-badge', '.gif'])
      animate(*image_data, tempfile.path)
      image = MiniMagick::Image.open(tempfile.path)
      tempfile.close
      image.to_blob
    end

    def setup_blank
      image = super
      image.scale('138x21')
    end

    def new_text_image(text, options) # rubocop:disable Metrics/MethodLength
      # Escape single quotes for ImageMagick draw command
      safe_text = text.to_s.gsub("'", "\\'")
      new_image do |convert|
        convert.size('87x14')
        convert << 'xc:white'

        convert.font BADGE_FONT_PATH
        convert.fill '#0082C6'
        convert.pointsize 9

        set_gravity(convert, options[:align])

        convert.motion_blur("0.0x#{options[:blur]}+90") if options[:blur] != 0
        convert.draw "text 0,#{options[:y_offset]} '#{safe_text}'"
      end
    end

    def add_text(text, options = {})
      options[:align] ||= :center

      image = setup_blank
      image.composite(new_text_image(text, options)) do |img|
        img.geometry '+48+3'
      end
    end

    def animate(*image_data, file_path)
      MiniMagick::Tool.new('convert') do |convert|
        first_image_options = image_data.shift
        scroll_to_bottom(convert, first_image_options)

        image_data.each do |options|
          scroll_from_top(convert, options)
          scroll_to_bottom(convert, options)
        end

        scroll_from_top(convert, first_image_options)
        convert << file_path
      end
    end

    def scroll_from_top(convert, options)
      convert_with_delay(convert, 5, options.merge(y_offset: -4, blur: 5))
      convert_with_delay(convert, 5, options.merge(y_offset: -1, blur: 3))
    end

    def scroll_to_bottom(convert, options)
      convert_with_delay(convert, 300, options.merge(y_offset: 0, blur: 0))
      convert_with_delay(convert, 5, options.merge(y_offset: 1, blur: 1))
      convert_with_delay(convert, 5, options.merge(y_offset: 6, blur: 5))
    end

    private_class_method :setup_blank, :new_text_image, :add_text, :animate,
                         :scroll_from_top, :scroll_to_bottom
  end
end
