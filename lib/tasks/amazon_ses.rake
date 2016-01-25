namespace :amazon_ses do
  # Note: This is a test to send one good email
  desc 'This task sends the initial reverification email'
  task first_reverification_email: :environment do
    ses = AWS::SimpleEmailService.new
    ses.send_email(
      to: 'drubio1989@gmail.com',
      subject: 'Good Email Test',
      from: 'info@openhub.net',
      body_text: 'This is a test email.'
      )
  end
end
