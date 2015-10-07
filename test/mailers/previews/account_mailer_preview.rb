class AccountMailerPreview < ActionMailer::Preview
  def reverification
    AccountMailer.reverification(Account.first)
  end

  def one_week_left
    AccountMailer.one_week_left(Account.first)
  end

  def one_day_left
    AccountMailer.one_day_left(Account.first)
  end

  def mark_as_spam
    AccountMailer.mark_as_spam(Account.first)
  end

  def one_month_left_before_deletion
    AccountMailer.one_month_left_before_deletion(Account.first)
  end

  def one_day_left_before_deletion
    AccountMailer.one_day_left_before_deletion(Account.first)
  end
end
