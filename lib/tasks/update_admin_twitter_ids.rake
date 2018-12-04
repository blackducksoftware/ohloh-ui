task update_admin_twitter_ids: :environment do
  admin_logins = %w[ohteam ohloh_slave]

  Account.where(login: admin_logins).each do |account|
    account.update! twitter_id: account.login
  end
end
