module ButtonHelper
  def disabled_button(text, opts = {})
    opts[:class] ||= ''
    opts[:class] << (logged_in? ? ' disabled' : ' needs_login')
    "<a href='#' class='btn #{opts[:class]}'>#{text}</a>".html_safe
  end

  def icon_button(url, options = {})
    linked_text = "<i class='icon-#{options.delete(:icon)}'>#{options.delete(:text)}</i>".html_safe
    link_to(linked_text, url, { class: "btn btn-#{options.delete(:size)} btn-#{options.delete(:type)}" }.merge(options))
  end
end
