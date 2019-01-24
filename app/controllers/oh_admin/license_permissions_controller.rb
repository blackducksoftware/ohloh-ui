class OhAdmin::LicensePermissionsController < ApplicationController
  before_action :admin_session_required
  before_action :check_params, only: [:index]
  layout 'admin'

  def index
    retrieve_license_permissions
    retrieve_licenses
    retrieve_license_rights
  end

  private

  def retrieve_license_permissions
    @license_permissions = LicenseLicensePermission
                           .includes(:license, license_permission: [:license_right])
                           .where(params[:query])
                           .order('licenses.id, license_permissions.id')
                           .paginate(page: page_param, per_page: 25)
  end

  def retrieve_licenses
    @licenses = License.all
                       .joins(:license_license_permissions)
                       .order(:name).uniq
                       .collect { |license| [license.name, license.id] }
  end

  def retrieve_license_rights
    @license_rights = LicenseRight.order(:name).collect { |right| [right.name, right.id] }
  end

  def check_params
    clear_params if params[:commit] == 'Clear Filter'
    build_query unless params[:commit] == 'Clear Filter'
  end

  def build_query
    p = params.slice(:license_id, :status, :license_right_id)
    params[:query] = p.map { |k, v| "#{k}=#{v}" if v.present? }.compact.join(' and ')
  end

  def clear_params
    scrubbed = %i[license_id status license_right_id]
    params.except!(*scrubbed)
  end
end
