module ButtonHelper
  def disabled_button(text, opts = {})
    css_class = "#{ opts[:class] } #{ needs_login_or_verification_or_default(:disabled) }".strip
    link_to text, 'javascript:', class: "btn #{ css_class }"
  end

  def icon_button(url, options = {})
    linked_text = "<i class='icon-#{options.delete(:icon)}'>#{options.delete(:text)}</i>".html_safe
    link_to(linked_text, url, { class: "btn btn-#{options.delete(:size)} btn-#{options.delete(:type)}" }.merge(options))
  end
end
