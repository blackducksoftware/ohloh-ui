# frozen_string_literal: true

module ManagersHelper
  def settings_parent_path(parent)
    parent.is_a?(Project) ? settings_project_path(parent) : settings_organization_path(parent)
  end

  def parent_managers_path(parent)
    parent.is_a?(Project) ? project_managers_path(parent) : list_managers_organization_path(parent)
  end

  def parent_manager_path(parent, manage)
    name = manage.account.to_param
    parent.is_a?(Project) ? project_manager_path(parent, name) : organization_manager_path(parent, name)
  end

  def new_parent_manager_path(parent)
    parent.is_a?(Project) ? new_project_manager_path(parent) : new_organization_manager_path(parent)
  end

  def edit_parent_manager_path(parent, account)
    parent.is_a?(Project) ? edit_project_manager_path(parent, account) : edit_organization_manager_path(parent, account)
  end

  def approve_parent_manager_path(obj, account)
    obj.is_a?(Project) ? approve_project_manager_path(obj, account) : approve_organization_manager_path(obj, account)
  end

  def reject_parent_manager_path(obj, account)
    obj.is_a?(Project) ? reject_project_manager_path(obj, account) : reject_organization_manager_path(obj, account)
  end

  def edit_manages_button(parent, account)
    url = edit_parent_manager_path(parent, account.to_param)
    link_to url, class: 'btn btn-md btn-primary' do
      content_tag(:i, '', class: 'icon-pencil') + ' ' + t('managers.manage.edit')
    end
  end

  def withdraw_manages_button(parent, account, name, target)
    url = reject_parent_manager_path(parent, account.to_param)
    link_to url, method: :post, class: 'btn btn-sm btn-danger',
                 title: t('managers.manage.withdraw_title', name: name, target: target),
                 data: { confirm: t('managers.manage.confirm_withdraw', name: name, target: target) } do
      content_tag(:i, '', class: 'icon-trash') + ' ' + t('managers.manage.withdraw')
    end
  end

  def approve_manages_button(parent, account, name, target)
    url = approve_parent_manager_path(parent, account.to_param)
    link_to url, method: :post, class: 'btn btn-sm btn-primary',
                 title: t('managers.manage.approve_title', name: name, target: target),
                 data: { confirm: t('managers.manage.confirm_approve', name: name, target: target) } do
      content_tag(:i, '', class: 'icon-thumbs-up') + ' ' + t('managers.manage.approve')
    end
  end

  def reject_manages_button(parent, account, name, target)
    url = reject_parent_manager_path(parent, account.to_param)
    link_to url, method: :post, class: 'btn btn-sm btn-danger',
                 title: t('managers.manage.reject_title', name: name, target: target),
                 data: { confirm: t('managers.manage.confirm_reject', name: name, target: target) } do
      content_tag(:i, '', class: 'icon-thumbs-down') + ' ' + t('managers.manage.reject')
    end
  end

  def remove_manages_button(parent, account, name, target)
    url = reject_parent_manager_path(parent, account.to_param)
    link_to url, method: :post, class: 'btn btn-md btn-danger',
                 data: { confirm: t('managers.manage.confirm_delete', name: name, target: target) } do
      content_tag(:i, '', class: 'icon-trash') + ' ' + t('managers.manage.remove_manager')
    end
  end
end
