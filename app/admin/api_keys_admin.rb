# frozen_string_literal: true

ActiveAdmin.register ApiKey do
  filter :oauth_application_secret_or_key, as: :string, label: 'Key'
  filter :name
  filter :description
  filter :total_count
  filter :daily_count
  filter :last_access_at
  filter :status, as: :select, collection: [['Active', ApiKey::STATUS_OK],
                                            ['Limit Exceeded', ApiKey::STATUS_LIMIT_EXCEEDED],
                                            ['Disabled', ApiKey::STATUS_DISABLED]]
  filter :url
  filter :support_url
  filter :callback_url

  index do
    column :id
    column :name do |api_key|
      name = api_key.name || api_key.try(:oauth_application).try(:name)
      link_to name, admin_api_key_path(api_key)
    end
    column :account do |api_key|
      link_to api_key.account.name, admin_account_path(api_key.account)
    end
    column :key do |api_key|
      key = api_key.try(:oauth_application).try(:secret) || api_key.key || I18n.t('api_keys.none')
      truncate(key, length: 20)
    end
    column :status do |api_key|
      case api_key.status
      when ApiKey::STATUS_OK
        status_tag('active', class: 'ok')
      when ApiKey::STATUS_LIMIT_EXCEEDED
        status_tag('limit exceeded', class: 'warning')
      else
        status_tag('disabled', class: 'error')
      end
    end
    column :total_count
    column :daily_count
    actions
  end

  show do
    attributes_table do
      rows :id, :created_at, :account, :key, :description, :daily_count, :daily_limit, :day_began_at, :last_access_at
      rows :total_count, :name, :url, :support_url, :callback_url, :secret, :oauth_application_id
      row :oauth_secret_key do |api_key|
        api_key.try(:oauth_application).try(:secret)
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs 'Details' do
      f.input :name, as: :string
      f.input :key, as: :string
      f.input :daily_limit
      f.input :status, as: :select, include_blank: false,
                       collection: { 'Active' => ApiKey::STATUS_OK,
                                     'Limit Exceeded' => ApiKey::STATUS_LIMIT_EXCEEDED,
                                     'Disabled' => ApiKey::STATUS_DISABLED }
      f.input :description, as: :text
      f.input :url, as: :url
      f.input :support_url, as: :url
      f.input :callback_url, as: :url
      f.input :secret, as: :string
    end
    f.actions
  end
end
