class Reverification < ActiveRecord::Base
  belongs_to :account

  @failed_emails = []
  @first_notification_error = []
  @second_notification_failure = []
  @third_notification_failure = []
  @fourth_notification_error = []

  class << self
    def populate_reverification_fields
      Account.where.not(twitter_id: nil).each do |account|
        account.create_reverification(twitter_reverified: true, twitter_reverification_sent_at: Time.now.utc)
        account.reload
      end
    end

    def send_reverification_emails(time = 900)
      Account.where(twitter_id: nil).find_in_batches do |batch_of_accounts|
        process_batch(batch_of_accounts)
        # Sleep for 15 minutes before processing another round of accounts
        sleep time
      end
    end

    def check_account_status
      Reverification.where(twitter_reverified: false).each do |reverification|
        reverification.calculate_status
        reverification.account.destroy if reverification.notification_counter == 5
        reverification.one_day_left_before_deletion
        reverification.one_month_left_before_deletion
        reverification.mark_as_spam
        reverification.one_day_left
        reverification.one_week_left
      end
    end

    def process_batch(batch_of_accounts)
      batch_of_accounts.each do |account|
        begin
          AccountMailer.reverification(account).deliver_now
        rescue
          @failed_emails << account.id
          next
        end
        account.create_reverification(twitter_reverification_sent_at: Time.now.utc)
      end
    end
  end # class << self

  def calculate_status
    @right_now = Time.now.utc
    @initial_email_date = twitter_reverification_sent_at
    @notification_counter = notification_counter
    if reminder_sent_at.present?
      @reminder_sent_at = reminder_sent_at
    else
      @reminder_sent_at = nil
    end
  end

  def one_day_left_before_deletion
    return if notification_counter < 4
    condition_one = (@right_now >= reminder_sent_at + 29.days)
    condition_two = (@right_now < reminder_sent_at + 30.days)
    process_email('one_day_left_before_deletion') if condition_one && condition_two
  end

  def one_month_left_before_deletion
    return if notification_counter < 3
    condition_one = (@right_now >= reminder_sent_at + 60.days)
    condition_two = (@right_now < reminder_sent_at + 89.days)
    process_email('one_month_left_before_deletion') if condition_one && condition_two
  end

  def mark_as_spam
    return if notification_counter < 2
    condition_one = @notification_counter == 2
    condition_two = @right_now >= twitter_reverification_sent_at + 30.days
    process_email('mark_as_spam') if (condition_one) && (condition_two)
  end

  # rubocop:disable Metrics/AbcSize
  def one_day_left
    return if notification_counter < 1
    last_chance_date = reminder_sent_at + 9.days
    mark_as_spam_date = reminder_sent_at + 10.days
    condition_one = (@right_now.to_i >= last_chance_date.to_i)
    condition_two = (@right_now.to_i < mark_as_spam_date.to_i)
    process_email('one_day_left') if condition_one && condition_two
  end

  def one_week_left
    return if notification_counter > 0
    condition_one = (@right_now.to_i >= (twitter_reverification_sent_at + 20.days).to_i)
    condition_two = (@right_now.to_i < (twitter_reverification_sent_at + 29.days).to_i)
    process_email('one_week_left') if condition_one && condition_two
  end
  # rubocop:enable Metrics/AbcSize

  private

  def update_reverification_fields
    self.notification_counter += 1
    self.reminder_sent_at = Time.now.utc
    self.save!
  end

  def process_email(delivery_method_name)
    begin
      Account::Access.new(account).spam! if delivery_method_name == 'mark_as_spam'
      AccountMailer.send("#{delivery_method_name}", account).deliver_now
    rescue
      @first_notification_error << account.id
      @second_notification_failure << account.id
      @third_notification_failure << account.id
      @fourth_notification_error << account.id
      @fourth_notification_failure << account.id
      return
    end
    update_reverification_fields
  end
end
