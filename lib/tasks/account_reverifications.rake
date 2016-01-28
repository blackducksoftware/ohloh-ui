namespace :openhub do
  # Note: This is a test to send one good email
  def ses
    ses = AWS::SimpleEmailService.new
  end

  def sqs
    sqs = AWS::SQS.new
  end

  def destroy_account(email_address)
    account = Account.find_by_email(email_address)
    account.destroy unless account == nil
  end

  def store_email_for_later_retry(email_address)
    sqs
    transient_bounce_queue = sqs.queues.named('ses-transientbounces-queue')
    transient_bounce_queue.send_message("#{email_address}")
  end

  def process_bounce(email) # Test for all of these cases
    email_address = email['bounce']['bouncedRecipients'][0]['emailAddress']
    bounce_type = email['bounce']['bounceType']
    bounce_subtype = email['bounce']['bounceSubType']
    if bounce_type == 'Undetermined'
      destroy_account(email_address)
    elsif bounce_type == 'Permanent'
        destroy_account(email_address)
      if bounce_subtype == 'General'
        destroy_account(email_address)
      elsif bounce_subtype == 'NoEmail'
        destroy_account(email_address)
      elsif bounce_subtype == 'Suppressed'
        destroy_account(email_address)
      end
    else bounce_type == 'Transient'
      if bounce_subtype == 'General'
        store_email_for_later_retry(email_address)
      elsif bounce_subtype == 'MailboxFull'
        store_email_for_later_retry(email_address)
      elsif bounce_subtype == 'MessageTooLarge'
        store_email_for_later_retry(email_address)
      elsif bounce_subtype == 'ContentRejected'
        store_email_for_later_retry(email_address)
      elsif bounce_subtype == 'AttachmentRejected'
        store_email_for_later_retry(email_address)
      end
    end
  end

  def queue
    bounce_queue = sqs.queues.named('ses-bounces-queue')
    bounce_queue.poll(initial_time: false, idle_timeout: 10) do |msg|
      process_bounce(msg.as_sns_message.body_message_as_h) 
    end
  end

  desc 'This task begins the initial reverification process'
  task send_first_reverification_email: :environment do
    # Grab a batch of 200 emails per 24 hour period.
    ses
    ses.send_email(
      to: 'ooto@simulator.amazonses.com',
      subject: 'SES complaint test',
      from: 'info@openhub.net',
      body_text: 'This is a complaint message.'
      )

    sqs
    queue
  end

  desc 'This task resends a reverification notice to soft bounce emails'
  task retry_notification: :environment do
    sqs
    transient_bounce_queue = sqs.queues.named('ses-transientbounces-queue')
    transient_bounce_queue.receive_message do |msg|
      ses
      ses.send_email(
      to: "#{msg.body}",
      subject: 'SES 2nd complaint test',
      from: 'info@openhub.net',
      body_text: 'This is a test email.'
      )
    end
    queue
  end 
end
