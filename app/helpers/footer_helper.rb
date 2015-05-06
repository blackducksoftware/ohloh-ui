module FooterHelper
  def selected?(params, link_class)
    return true if params == 'settings' && link_class.to_s == 'settings'
    return true if params == 'edit' && link_class.to_s == 'settings'
    return true if params == 'index' && link_class.to_s == 'settings'
  end
end
