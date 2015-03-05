module BootstrapHelper
  def bootstrap_icon(name, text = nil)
    "<i class='#{name}'>#{text == '' ? '' : '&nbsp;'}</i>#{text || ''}"
  end

  def bootstrap_mini_button_link_to(text, path, opts = {})
    opts[:class] = "btn btn-mini #{opts[:class] || ''}"
    link_to(text, path, opts)
  end

  def bootstrap_small_button_link_to(text, path, opts = {})
    opts[:class] = "btn btn-small #{opts[:class] || ''}"
    link_to(text, path, opts)
  end

  def bootstrap_button_link_to(text, path, opts = {})
    opts[:class] = "btn #{opts[:class] || ''}"
    link_to(text, path, opts)
  end

  def bootstrap_large_button_link_to(text, path, opts = {})
    opts[:class] = "btn btn-large #{opts[:class] || ''}"
    link_to(text, path, opts)
  end

  def bootstrap_link_to(text, path, opts = {})
    opts[:class] = "help-block btn-mini #{opts[:class] || ''}"
    link_to(text, path, opts)
  end
end
