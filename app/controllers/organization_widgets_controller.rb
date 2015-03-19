class OrganizationWidgetsController < WidgetsController
  before_action :set_organization
  before_action :render_not_supported_thin_badge
  before_action :render_for_js_format

  def index
    @widgets = OrganizationWidget.create_widgets(params[:organization_id])
  end

  private

  def set_organization
    @organization = Organization.active.from_param(params[:organization_id]).first
  end
end
