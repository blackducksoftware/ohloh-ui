module LicenseHelper
  def categorize_permission(permission)
    permission_exists = permission['license_permission_id'].present?
    new_permission_status = params['right_' + permission['id']]
    new_permission_exists = new_permission_status.present?

    # skip if permission was not originally set and remains unset
    return if !permission_exists && !new_permission_exists

    permission['license_id'] = params['license_id']
    set_param_condition(permission_exists, new_permission_exists, new_permission_status, permission)
  end

  def save_changes
    create_permissions
    update_permissions
    delete_permissions
  end

  private

  def set_param_condition(permission_exists, new_permission_exists, new_permission_status, permission_hash)
    is_new_permission = check_new_permission(permission_exists, new_permission_exists,
                                             new_permission_status, permission_hash)
    return if is_new_permission

    is_updated_permission = check_updated_permission(new_permission_exists,
                                                     new_permission_status, permission_hash)
    return if is_updated_permission

    # permission originally set but is now unset - permission record to be deleted
    @delete_list << permission_hash unless new_permission_exists
  end

  def check_new_permission(permission_exists, new_permission_exists, new_permission_status, permission_hash)
    return unless !permission_exists && new_permission_exists
    permission_hash['status'] = new_permission_status
    @create_list << permission_hash
  end

  def check_updated_permission(new_permission_exists, new_permission_status, permission_hash)
    return unless new_permission_exists && new_permission_status != permission_hash['status']
    permission_hash['status'] = new_permission_status
    @update_list << permission_hash
  end

  def create_permissions
    @create_list.each do |permission|
      lp = LicensePermission.find_by license_right_id: permission['id'], status: permission['status']
      llp = LicenseLicensePermission.new(license_id: permission['license_id'],
                                         license_permission_id: lp.id,
                                         created_at: Time.zone.now.getutc,
                                         updated_at: Time.zone.now.getutc)
      llp.save
    end
  end

  def update_permissions
    @update_list.each do |permission|
      lp = LicensePermission.find_by license_right_id: permission['id'], status: permission['status']
      llp = LicenseLicensePermission.find permission['license_license_permission_id']
      llp.license_permission_id = lp.id
      llp.save
    end
  end

  def delete_permissions
    @delete_list.each do |permission|
      llp = LicenseLicensePermission.find permission['license_license_permission_id']
      llp.delete
    end
  end
end
