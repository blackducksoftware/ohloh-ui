# frozen_string_literal: true

module ButtonHelper
  def disabled_button(text, opts = {})
    css_class = "#{opts[:class]} #{needs_login_or_verification_or_default(:disabled)}".strip
    link_to text.html_safe, 'javascript:', class: "btn #{css_class}"
  end

  def icon_button(url, options = {})
    linked_text = "<i class='icon-#{options.delete(:icon)}'>&nbsp;</i>#{options.delete(:text)}".html_safe
    link_to(sanitize(linked_text), url, { class: "btn btn-#{options.delete(:size)} btn-#{options.delete(:type)}" }.merge(options))
  end
end
