namespace :amazon_ses do
  # Note: This is a test to send one good email
  desc 'This task sends the initial reverification email'
  task first_reverification_email: :environment do
    ses = AWS::SimpleEmailService.new
    ses.send_email(
      to: 'complaint@simulator.amazonses.com',
      subject: 'Good Email Test',
      from: 'info@openhub.net',
      body_text: 'This is a test email.'
      )

    def process_bounce(email) # Test for all of these cases
      bounce_type = email['bounce']['bounceType']
      bounce_subtype = email['bounce']['bounceSubType']
      if bounce_type == 'Undetermined'
        # try again later
      elsif bounce_type == 'Permanent'
          # Remove email from list
        if bounce_subtype == 'General'
          # Remove email from list
        elsif bounce_subtype == 'NoEmail'
          # Remove email from list
        elsif bounce_subtype == 'Suppressed'
          # Remove email from list
        end
      else bounce_type == 'Transient'
        if bounce_subtype == 'General'
          # Try again later
        elsif bounce_subtype == 'MailboxFull'
          # Try again later
        elsif bounce_subtype == 'MessageTooLarge'
          # Try again later
        elsif bounce_subtype == 'ContentRejected'
          # Try again later
        elsif bounce_subtype == 'AttachmentRejected'
          # Try again later
        end
      end
    end

    def process_complaint(email)
      # Ask Peter about what exactly to do with complained recipients
      complained_recipient = email['complaint']['complainedRecipients'][0]['emailAddress']
      complaint_feedback_type = email['complaint']['complaintFeedbackType']
    end

    sqs = AWS::SQS.new
    # bounce_queue = sqs.queues.named('ses-bounces-queue')
    complaint_queue = sqs.queues.named('ses-complaints-queue')

    # bounce_queue.poll(initial_time: false, idle_timeout: 10) do |msg|
    #   puts "==========#{msg.as_sns_message.body_message_as_h}============" 
    #   process_bounce(msg.as_sns_message.body_message_as_h) 
    # end
    
    complaint_queue.poll(initial_time: false, idle_timeout: 10) do |msg|
      puts "==========#{msg.as_sns_message.body_message_as_h}============" 
      process_complaint(msg.as_sns_message.body_message_as_h) 
    end
  end
end
