module BootstrapHelper
  def bootstrap_icon(name, text = nil)
    "<i class='#{name}'>#{text == '' ? '' : '&nbsp;'}</i>#{text || ''}"
  end
end
