# frozen_string_literal: true

task update_admin_twitter_ids: :environment do
  admin_logins = %w[ohteam ohloh_slave]

  Account.where(login: admin_logins).find_each do |account|
    account.update! twitter_id: account.login
  end
end
