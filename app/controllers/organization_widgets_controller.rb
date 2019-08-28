# frozen_string_literal: true

class OrganizationWidgetsController < WidgetsController
  before_action :set_organization
  before_action :render_not_supported_for_gif_format
  before_action :render_iframe_for_js_format
  before_action :organization_context, only: :index

  def index
    @widgets = OrganizationWidget.create_widgets(params[:organization_id])
  end

  private

  def set_organization
    @organization = Organization.from_param(params[:organization_id]).first!
  end
end
