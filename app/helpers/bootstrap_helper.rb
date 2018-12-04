module BootstrapHelper
  def bootstrap_icon(name, text = nil)
    # rubocop:disable Rails/OutputSafety # The variables used here are known values.
    "<i class='#{name}'>#{text == '' ? '' : '&nbsp;'}</i>#{text || ''}".html_safe
    # rubocop:enable Rails/OutputSafety
  end
end
