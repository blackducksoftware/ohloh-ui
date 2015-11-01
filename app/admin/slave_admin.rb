ActiveAdmin.register Slave do
  config.sort_order = 'id_asc'
  permit_params :hostname, :allow_deny, :enable_profiling
  remove_filter :jobs

  index do
    column :id
    column :hostname do |host|
      # Seriously, ActiveAdmin, the singular of "slaves" is "slafe"??!!
      link_to host.hostname, admin_slafe_path(host)
    end
    column :load_average
    column :allow_deny do |ad|
      case ad.allow_deny
      when 'allow'
        status_tag('Allow', :ok)
      when 'deny'
        status_tag('Deny', :error)
      else
        status_tag('ERROR', :error)
      end
    end
    column :used_percent
    column :clump_status
    column 'Clump Age' do |record| 
      if record.oldest_clump_timestamp
        time_ago_in_words(record.oldest_clump_timestamp)
      else
        "no oldest clump"
      end
    end
    column :blocked_types
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs 'Details' do
      f.input :hostname, as: :string
      f.input :allow_deny, as: :select, include_blank: false,
              collection: {'Allow' => 'allow', 'Deny' => 'deny'}
      f.input :enable_profiling, as: :select, include_blank: false,
              collection: {'Yes' => 'true', 'No' => 'false'}
      f.input :blocked_types
    end
    f.actions
  end
end
