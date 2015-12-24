ActiveAdmin.register Slave do
  config.sort_order = 'id_asc'
  permit_params :hostname, :allow_deny, :enable_profiling
  remove_filter :jobs

  config.batch_actions = true
  batch_action :destroy, false

  batch_action :deny do |ids|
    Slave.where(id: ids).update_all(allow_deny: 'deny')
    redirect_to collection_path, alert: 'The slaves have been set to denied.'
  end

  batch_action :allow do |ids|
    Slave.where(id: ids).update_all(allow_deny: 'allow')
    redirect_to collection_path, alert: 'The slaves have been set to allowed.'
  end

  filter :hostname
  filter :allow_deny, as: :select
  filter :blocked_types

  index row_class: -> (elem) { 'deny' if elem.deny? } do
    selectable_column
    column :id
    column :hostname do |host|
      # Seriously, ActiveAdmin, the singular of "slaves" is "slafe"??!!
      link_to host.hostname, admin_slafe_path(host)
    end
    column :load_average
    column :allow_deny do |ad|
      case ad.allow_deny.to_s.downcase
      when 'allow'
        status_tag('Allow', :ok)
      when 'deny'
        status_tag('Deny', :error)
      end
    end
    column :used_percent
    column :clump_status
    column 'Clump Age' do |slave|
      if slave.oldest_clump_timestamp
        time_ago_in_words(slave.oldest_clump_timestamp)
      else
        'no oldest clump'
      end
    end
    column :blocked_types
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs 'Details' do
      f.input :hostname, as: :string
      f.input :allow_deny, as: :select, include_blank: false, collection: { 'Allow' => 'allow', 'Deny' => 'deny' }
      f.input :enable_profiling, as: :select, include_blank: false, collection: { 'Yes' => 'true', 'No' => 'false' }
      f.input :blocked_types
    end
    f.actions
  end
end
