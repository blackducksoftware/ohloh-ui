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
    # rubocop:disable Rails/SkipsModelValidations # We want a quick DB update here.
    account.update_attribute(attribute_name, false)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def generate_unsubscription_key
    CGI.unescape(Ohloh::Cipher.encrypt(account.id.to_s))
  end
end
