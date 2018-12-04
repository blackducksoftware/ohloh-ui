module ButtonHelper
  def disabled_button(text, opts = {})
    css_class = "#{opts[:class]} #{needs_login_or_verification_or_default(:disabled)}".strip
    # rubocop:disable Rails/OutputSafety # `text` always points to static I18n values.
    link_to text.html_safe, 'javascript:', class: "btn #{css_class}"
    # rubocop:enable Rails/OutputSafety
  end

  def icon_button(url, options = {})
    # rubocop:disable Rails/OutputSafety # Static values are being used.
    linked_text = "<i class='icon-#{options.delete(:icon)}'>&nbsp;</i>#{options.delete(:text)}".html_safe
    # rubocop:enable Rails/OutputSafety
    link_to(linked_text, url, { class: "btn btn-#{options.delete(:size)} btn-#{options.delete(:type)}" }.merge(options))
  end
end
