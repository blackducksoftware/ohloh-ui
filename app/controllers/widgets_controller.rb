class WidgetsController < ApplicationController
  helper :widgets
  before_action :set_widget, except: :index
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  layout :false, except: :index

  private

  def record_not_found
    render text: 'Sorry, the widget you requested could not be found.'
  end

  def set_widget
    @widget = Object.const_get("#{controller_name.camelize[0..-2]}::#{action_name.camelize}").new(params)
  end

  def render_gif_image
    return unless request.format.gif?
    send_data(@widget.image, disposition: 'inline', type: 'image/gif', filename: 'widget.gif', status: 200)
  end

  def render_not_supported_thin_badge
    return unless request.format.gif?
    image = ThinBadge.create('Not supported')
    send_data(image, disposition: 'inline', type: 'image/gif', filename: 'widget.gif', status: 406)
  end

  def render_for_js_format
    return unless request.format.js?
    render :iframe
  end
end
