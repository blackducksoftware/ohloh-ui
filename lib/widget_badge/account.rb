# frozen_string_literal: true

module WidgetBadge
  module Account
    module_function

    include BadgeHelper

    DEFAULT_FONT_OPTIONS = { opacity: 80, font_size: 12, stroke: :none, weight: 800,
                             align: :left, y_offset: 5 }.freeze
    IMAGE_ICONS_DIR = Rails.root.join('app', 'assets', 'images', 'icons')
    TEXT_OFFSET = { left: 82 }.freeze
    KUDO_OFFSET = { left: 200 }.freeze

    def create(options = {})
      image = setup_blank
      image = add_kudos(image, options[:kudo_rank]) if options[:kudo_rank]
      image = add_text(image, options)
      image.to_blob
    end

    def add_text(image, options)
      modified_image = add_name(image, options[:name])

      commits_count = options[:commits].to_i
      commits = "#{commits_count} commit".pluralize(commits_count) if commits_count.positive?

      kudos_count = options[:kudos].to_i
      kudos = "#{kudos_count} kudo".pluralize(kudos_count) if kudos_count.positive?

      add_commits_and_kudos(modified_image, commits, kudos)
    end

    def new_text_image(text, options)
      new_image do |convert|
        convert.size('160x20')
        convert << 'xc:none'

        set_font_and_color(convert, options)
        set_gravity(convert, options[:align])

        convert.draw "text 0,#{options[:y_offset] - 8} '#{text.gsub("'") { |ch| "\\#{ch}" }}'"
      end
    end

    def kudos_filename(kudo_rank = 1)
      IMAGE_ICONS_DIR.join("sm_laurel_#{kudo_rank}.png")
    end

    def kudos_image(kudo_rank = 1)
      image = MiniMagick::Image.open(kudos_filename(kudo_rank))
      image.background('none')
      image
    end

    def add_kudos(image, kudo_rank = 1)
      image.composite(kudos_image(kudo_rank)) do |img|
        img.geometry "+#{KUDO_OFFSET[:left]}+5"
      end
    end

    def add_name(image, name)
      return image if name.blank?

      options = DEFAULT_FONT_OPTIONS.merge(font_size: 13)
      image.composite(new_text_image(name.truncate(16), options)) do |img|
        img.geometry "+#{TEXT_OFFSET[:left]}+5"
      end
    end

    def add_commits_and_kudos(image, commits, kudos)
      commits_and_kudos = [commits, kudos].compact.join(', ')
      return image if commits_and_kudos.blank?

      options = DEFAULT_FONT_OPTIONS.merge(opacity: 70, font_size: 10)
      image.composite(new_text_image(commits_and_kudos.truncate(26), options)) do |img|
        img.geometry "+#{TEXT_OFFSET[:left]}+22"
      end
    end

    private_class_method :add_text, :new_text_image, :kudos_filename, :kudos_image, :add_kudos,
                         :add_name, :add_commits_and_kudos
  end
end
