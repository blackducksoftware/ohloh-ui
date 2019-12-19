# frozen_string_literal: true

module BootstrapHelper
  def bootstrap_icon(name, text = nil)
    "<i class='#{name}'>#{text == '' ? '' : '&nbsp;'}</i>#{text || ''}".html_safe
  end
end
