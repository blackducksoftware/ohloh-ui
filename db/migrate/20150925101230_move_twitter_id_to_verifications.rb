# frozen_string_literal: true

class MoveTwitterIdToVerifications < ActiveRecord::Migration
  def up
    Account.where('twitter_id is not null').each do |account|
      next if account.twitter_digits_verification

      verification = account.build_twitter_digits_verification
      verification.auth_id = account.twitter_id
      verification.save(validate: false)
    end
  end

  def down
    Account.joins(:twitter_digits_verification).each do |account|
      account.twitter_id = account.twitter_digits_verification.auth_id
      account.save(validate: false)
      account.twitter_digits_verification.destroy
    end
  end
end
