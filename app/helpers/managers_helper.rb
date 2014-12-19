module ManagersHelper
  def edit_manages_button(parent, account)
    url = edit_project_manager_path(parent, account.to_param)
    icon_button(url, size: 'small', type: 'success', icon: 'pencil', text: t('managers.manage.edit'))
  end

  def withdraw_manages_button(parent, account, name, target)
    url = reject_project_manager_path(parent, account.to_param)
    confirm = t('managers.manage.confirm_withdraw', name: name, target: target)
    title = t('managers.manage.withdraw_title', name: name, target: target)
    icon_button(url, size: 'small', type: 'danger', icon: 'trash', method: :post,
                     text: t('managers.manage.withdraw'), data: { confirm: confirm }, title: title)
  end

  def approve_manages_button(parent, account, name, target)
    url = reject_project_manager_path(parent, account.to_param)
    confirm = t('managers.manage.confirm_approve', name: name, target: target)
    title = t('managers.manage.approve_title', name: name, target: target)
    icon_button(url, size: 'small', type: 'success', icon: 'thumbs-up', method: :post,
                     text: t('managers.manage.approve'), data: { confirm: confirm }, title: title)
  end

  def reject_manages_button(parent, account, name, target)
    url = reject_project_manager_path(parent, account.to_param)
    confirm = t('managers.manage.confirm_reject', name: name, target: target)
    title = t('managers.manage.reject_title', name: name, target: target)
    icon_button(url, size: 'small', type: 'danger', icon: 'thumbs-down', method: :post,
                     text: t('managers.manage.reject'), data: { confirm: confirm }, title: title)
  end

  def remove_manages_button(parent, account, name, target)
    url = reject_project_manager_path(parent, account.to_param)
    confirm = t('managers.manage.confirm_delete', name: name, target: target)
    icon_button(url, size: 'small', type: 'danger', icon: 'trash', method: :post,
                     text: t('managers.manage.remove_manager'), data: { confirm: confirm })
  end
end
