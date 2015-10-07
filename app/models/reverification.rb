class Reverification < ActiveRecord::Base
  belongs_to :account

  attr_reader :undeliverable_account
  # rubocop: disable Style/ClassVars
  @@undeliverable_accounts = []
  UndeliverableAccount = Struct.new(:account_id, :error_message)

  class << self
    # This method creates a seperate reverifications association for the reverification process.
    def create_and_populate_reverification_fields
      Account.find_each do |account|
        account.create_reverification
        account.reverification.update(verified: true) if Account::Access.new(account).verified?
        account.reload
      end
    end

    def send_reverification_emails(time = 900)
      Reverification.where(verified: false).find_in_batches do |batch_of_reverifications|
        process_batch(batch_of_reverifications)
        # Sleep for 15 minutes before processing another round of accounts
        sleep time
      end
    end

    def check_account_status
      Reverification.where(verified: false).each do |reverification|
        reverification.calculate_status
        reverification.account.destroy if reverification.notification_counter == 5
        reverification.one_day_left_before_deletion
        reverification.one_month_left_before_deletion
        reverification.mark_as_spam
        reverification.one_day_left
        reverification.one_week_left
      end
    end

    def process_batch(batch_of_reverifications)
      batch_of_reverifications.each do |reverification|
        account = reverification.account
        begin
          AccountMailer.reverification(account).deliver_now
        rescue Net::SMTPError => e
          @@undeliverable_accounts << UndeliverableAccount(account.id, e.message)
          next
        end
        reverification.update(initial_email_sent_at: Time.now.utc)
      end
    end
  end # class << self

  def calculate_status
    @right_now = Time.now.utc
  end

  def one_day_left_before_deletion
    return if notification_counter < 4
    condition_one = gt_equal(reminder_sent_at + 29.days)
    condition_two = less_than(reminder_sent_at + 30.days)
    process_email('one_day_left_before_deletion') if condition_one && condition_two
  end

  def one_month_left_before_deletion
    return if notification_counter < 3
    condition_one = gt_equal(reminder_sent_at + 60.days)
    condition_two = less_than(reminder_sent_at + 89.days)
    process_email('one_month_left_before_deletion') if condition_one && condition_two
  end

  def mark_as_spam
    return if notification_counter < 2
    condition_one = notification_counter == 2
    condition_two = gt_equal(initial_email_sent_at + 30.days)
    process_email('mark_as_spam') if (condition_one) && (condition_two)
  end

  # rubocop:disable Metrics/AbcSize
  def one_day_left
    return if notification_counter < 1
    condition_one = gt_equal(reminder_sent_at + 9.days)
    condition_two = less_than(reminder_sent_at + 10.days)
    process_email('one_day_left') if condition_one && condition_two
  end

  def one_week_left
    return if notification_counter > 0
    condition_one = gt_equal(initial_email_sent_at + 20.days)
    condition_two = less_than(initial_email_sent_at + 29.days)
    process_email('one_week_left') if condition_one && condition_two
  end
  # rubocop:enable Metrics/AbcSize

  private

  def gt_equal(date)
    @right_now >= date
  end

  def less_than(date)
    @right_now < date
  end

  def update_reverification_fields
    self.notification_counter += 1
    self.reminder_sent_at = Time.now.utc
    self.save!
  end

  def process_email(delivery_method_name)
    begin
      Account::Access.new(account).spam! if delivery_method_name == 'mark_as_spam'
      AccountMailer.send("#{delivery_method_name}", account).deliver_now
    rescue Net::SMTPError => e
      @@undeliverable_accounts << UndeliverableAccount(account.id, e.message)
      return
    end
    update_reverification_fields
  end
end
