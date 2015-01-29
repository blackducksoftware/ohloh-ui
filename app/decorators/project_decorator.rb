class ProjectDecorator < Draper::Decorator
  def icon(size = :small, opts = {})
    opts[:color] = h.language_text_color(main_language)
    opts[:bg]    = h.language_color(main_language)

    icon = Icon.new(object, context: { size: size, opts: opts})
    icon.image
  end
end
