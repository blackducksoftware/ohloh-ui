module ApplicationHelper
  def blog_link_to(name:, link_text:)
    "<a class='meta' href='http://blog.openhub.net/#{name}' target='_blank'>#{link_text}</a>"
  end

  def error_tag(model, attr, opts = {})
    return '' if model.nil?
    err = model.errors[attr]
    return '' if err.blank?
    haml_tag 'p', [err].flatten.join('<br />'), opts.reverse_merge(class: 'error').merge(rel: attr)
  end
end
