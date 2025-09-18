# frozen_string_literal: true

class MoveTwitterIdToVerifications < ActiveRecord::Migration[4.2]
  def up
    Account.where.not(twitter_id: nil).find_each do |account|
      next if account.twitter_digits_verification

      verification = account.build_twitter_digits_verification
      verification.auth_id = account.twitter_id
      verification.save(validate: false)
    end
  end

  def down
    Account.joins(:twitter_digits_verification).find_each do |account|
      account.twitter_id = account.twitter_digits_verification.auth_id
      account.save(validate: false)
      account.twitter_digits_verification.destroy
    end
  end
end
