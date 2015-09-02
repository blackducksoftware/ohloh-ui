ActiveAdmin.register Account do
  permit_params :level

  controller do
    defaults finder: :fetch_by_login_or_email
  end

  filter :login
  filter :email
  filter :name
  filter :level, as: :select, collection: [['Default', Account::Access::DEFAULT],
                                           ['Admin', Account::Access::ADMIN],
                                           ['Disabled', Account::Access::DISABLED],
                                           ['Spammer', Account::Access::SPAM]]
  filter :last_seen_ip

  index do
    column :id
    column :name do |account|
      link_to account.name, account_path(account)
    end
    column :login
    column :email
    column :level do |account|
      case account.level
      when Account::Access::DEFAULT
        status_tag('default', :ok)
      when Account::Access::ADMIN
        status_tag('admin', :warning)
      when Account::Access::DISABLED
        status_tag('disabled', :error)
      else
        status_tag('spammer', :error)
      end
    end
    column :url
    column :last_seen_ip do |account|
      ip = account.last_seen_ip
      ip.blank? ? '' : link_to(ip, admin_accounts_path('q[last_seen_ip_contains]' => ip, 'commit' => 'Filter'))
    end
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs 'Details' do
      f.input :login, as: :string
      f.input :email, as: :string
      f.input :name, as: :string
      f.input :level, as: :select, include_blank: false,
                      collection: { 'Default' => Account::Access::DEFAULT,
                                    'Admin' => Account::Access::ADMIN,
                                    'Disabled' => Account::Access::DISABLED,
                                    'Spammer' => Account::Access::SPAM }
      f.input :country_code, as: :string
      f.input :location, as: :string
      f.input :url, as: :url
      f.input :hide_experience
      f.input :email_master
      f.input :email_posts
      f.input :email_kudos
      f.input :email_new_followers
      f.input :twitter_account, as: :string
      f.input :affiliation_type, as: :string
      f.input :organization_name, as: :string
      f.input :twitter_id, label: "Twitter Digits ID"
    end
    f.actions
  end
end
