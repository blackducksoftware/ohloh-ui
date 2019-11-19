# frozen_string_literal: true

class Account::Subscription
  attr_reader :account

  def initialize(account)
    @account = account
  end

  def unsubscribe(notification_type = :all)
    attribute_name = case notification_type
                     when :kudo then :email_kudos
                     when :post then :email_posts
                     else :email_master
                     end
    account.update_attribute(attribute_name, false)
  end

  def generate_unsubscription_key
    CGI.unescape(Ohloh::Cipher.encrypt(account.id.to_s))
  end
end
