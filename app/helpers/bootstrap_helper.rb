# frozen_string_literal: true

module BootstrapHelper
  def bootstrap_icon(name, text = nil)
    "<i class='#{name}'>#{'&nbsp;' unless text == ''}</i>#{text || ''}".html_safe
  end
end
