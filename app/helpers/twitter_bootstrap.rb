module TwitterBootstrap
  module IconHelper
    def bootstrap_icon(name, text = nil)
      "<i class='#{name}'>#{text == '' ? '' : '&nbsp;'}</i>#{text || ''}".html_safe
    end
  end
end
