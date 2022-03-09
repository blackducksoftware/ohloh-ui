# frozen_string_literal: true

class OhAdmin::LicensePermissionsController < ApplicationController
  before_action :admin_session_required
  before_action :check_params, only: [:index]
  before_action :get_permissions, only: %i[new update]
  layout 'admin'
  include LicenseHelper

  def index
    retrieve_license_permissions
    retrieve_licenses
    retrieve_license_rights
  end

  def new
    retrieve_licenses
    render
  end

  def create
    @create_list = []
    @update_list = []
    @delete_list = []
    parse_params
    save_changes
    redirect_to oh_admin_license_permissions_path, notice: 'Changes Saved'
  end

  def get_permissions
    retrieve_permission_rights
  end

  private

  def parse_params
    original_hash = get_permissions

    original_hash.each do |permission|
      categorize_permission(permission)
    end
  end

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

  def get_sql(license_id)
    "select lr.id, lr.name, t.license_permission_id, license_license_permission_id, t.license_id, t.status
    from license_rights lr
    left outer join
    (select lp.license_right_id, lp.id, llp.license_id as license_id, lp.id as license_permission_id,
        llp.id as license_license_permission_id, lp.status
      from license_permissions lp
      join license_license_permissions llp on lp.id = llp.license_permission_id
      where llp.license_id = #{license_id})t on t.license_right_id = lr.id
    order by lr.id ;"
  end

  def retrieve_permission_rights
    return unless params[:license_id]

    license_id = params[:license_id]
    sql = get_sql(license_id)
    @permission_rights = ApplicationRecord.connection.select_all(sql).to_hash
  end

  def check_params
    clear_params if params[:commit] == 'Clear Filter'
    build_query unless params[:commit] == 'Clear Filter'
  end

  def permitted_params
    params.permit(:license_id, :status, :license_right_id, :commit)
  end

  def build_query
    p = permitted_params.slice(:license_id, :status, :license_right_id).to_h
    params[:query] = p.map { |k, v| "#{k}=#{v}" if v.present? }.compact.join(' and ')
  end

  def clear_params
    scrubbed = %i[license_id status license_right_id]
    permitted_params.to_h.except!(*scrubbed)
  end
end
