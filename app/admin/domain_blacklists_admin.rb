ActiveAdmin.register DomainBlacklist do
  index do
    column :id
    column :domain do |domain_blacklist|
      params = { 'q[email_contains]' => domain_blacklist.domain, 'commit' => 'Filter' }
      link_to domain_blacklist.domain, admin_accounts_path(params)
    end
    actions
  end
end
