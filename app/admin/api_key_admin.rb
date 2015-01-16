ActiveAdmin.register ApiKey do
  filter :key
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
      link_to api_key.name, admin_api_key_path(api_key)
    end
    column :account
    column :key
    column :status do |api_key|
      case api_key.status
      when ApiKey::STATUS_OK
        status_tag('active', :ok)
      when ApiKey::STATUS_LIMIT_EXCEEDED
        status_tag('limit exceeded', :warning)
      else
        status_tag('disabled', :error)
      end
    end
    column :total_count
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
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
