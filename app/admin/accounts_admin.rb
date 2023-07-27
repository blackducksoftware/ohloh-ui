# frozen_string_literal: true

ActiveAdmin.register Account do
  account_params = %i[login email name country_code location url twitter_account
                      affiliation_type organization_name level]
  permit_params account_params
  actions :index, :show, :edit, :update

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
  filter :last_seen_at
  filter :last_seen_ip
  filter :created_at

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
        status_tag('default', class: 'ok')
      when Account::Access::ADMIN
        status_tag('admin', class: 'warning')
      when Account::Access::DISABLED
        status_tag('disabled', class: 'error')
      else
        status_tag('spammer', class: 'error')
      end
    end
    column :url
    column :last_seen_at
    column :last_seen_ip do |account|
      ip = account.last_seen_ip
      ip.blank? ? '' : link_to(ip, admin_accounts_path('q[last_seen_ip_contains]' => ip, 'commit' => 'Filter'))
    end
    column :created_at
    column 'Markup' do |acc|
      markup = acc.markup.try :raw
      div(title: markup) do
        truncate(markup, length: 10)
      end
    end
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs 'Details' do
      account_params.exclude(:level).each do |field|
        f.input field, as: :string
      end
      f.input :level, as: :select, include_blank: false,
                      collection: { 'Default' => Account::Access::DEFAULT,
                                    'Admin' => Account::Access::ADMIN,
                                    'Disabled' => Account::Access::DISABLED,
                                    'Spammer' => Account::Access::SPAM }
    end
    f.actions
  end

  action_item :reset_password, only: :show do
    link_to 'Reset Password',
            reset_password_admin_account_path(params[:id])
  end

  member_action :reset_password do
    account = Account.find_by(login: params[:id])
    account.password = SecureRandom.hex(16)
    account.save!
    AccountMailer.reset_password(account.id).deliver
    flash[:notice] = "Account #{account.email}'s password has been changed."
    redirect_to admin_account_path(params[:id])
  end
end
