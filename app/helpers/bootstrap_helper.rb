# frozen_string_literal: true

module BootstrapHelper
  def bootstrap_icon(name, text = nil)
    safe_text("<i class='#{name}'>#{text == '' ? '' : '&nbsp;'}</i>#{text || ''}")
  end
end
