module Reverification
  class Template
    class << self
      # def one_day_before_deletion_notice(email)
      #   { to: "#{email}",
      #     subject: 'Your Account Will Be Deleted Tomorrow: Please Reverify',
      #     from: 'info@openhub.net',
      #     body_html:  "Hello, you are receiving this notice because Open Hub has determined that this account is spam
      #       and will be deleted from the website tomorrow. If this is incorrect, please click on the reverification link
      #       <a href=#{ENV['URL_HOST']}/authentications/new /> in order to restore your account. Failure to do so by tomorrow
      #       will result in your account's deletion and will no longer be able to be restored.
      #       Please reverify your account by tomorrow so that you may continue to enjoy our services.

      #       Sincerely,

      #       The Open Hub Team

      #       8 New England Executive Park, Burlington, MA 01803" }
      # end

      # def account_is_spam_notice(email)
      #   { to: "#{email}",
      #     subject: 'Your Account Status Has Converted to Spam',
      #     from: 'info@openhub.net',
      #     body_html:  "Hello, you are receiving this notice because Open Hub has determined that this account is spam
      #       and has changed the status of your account to spam in its system. If this is incorrect, please click
      #       on the reverification link <a href=#{ENV['URL_HOST']}/authentications/new /> in order to restore your account. Failure
      #       to do so will result in your account's eventual deletion. Please reverify your account within 7 days
      #       so that you may continue to enjoy our services. Please note that if you fail
      #       to verify in this time period, your account and all data associated it will be deleted from the system.

      #       Sincerely,

      #       The Open Hub Team

      #       8 New England Executive Park, Burlington, MA 01803" }
      # end

      # # Note: Don't forget to internationalize and test
      # def marked_for_spam_notice(email)
      #   { to: "#{email}",
      #     subject: 'Account Marked for Spam',
      #     from: 'info@openhub.net',
      #     body_html:  "As an effort to eliminate excessive spam accounts, Open Hub has provided you the following link in order
      #       to reverify your account with us. Please click on the reverification link <a href=#{ENV['URL_HOST']}/authentications/new />
      #       within 24 hours so that you may continue to enjoy our services. Please note that if you fail
      #       to verify your account within 24 hours, Open Hub will flag your account as spam. Thank you.

      #       Sincerely,

      #       The Open Hub Team

      #       8 New England Executive Park, Burlington, MA 01803" }
      # end

      # Note: Don't forget to internationalize and test
      def first_reverification_notice(email)
        { to: "#{email}",
          subject: 'Please Reverify Your Open Hub Account',
          from: 'info@openhub.net',
          body_html:  "As an effort to eliminate excessive spam accounts, Open Hub has provided you the following link in order
            to reverify your account with us. Please click on the reverification link <a href=#{ENV['URL_HOST']}/authentications/new />
            within 2 weeks so that you may continue to enjoy our services. Please note that if you fail
            to verify your account within 2 weeks, Open Hub will flag your account as spam. Thank you.

            Sincerely,

            The Open Hub Team

            8 New England Executive Park, Burlington, MA 01803" }
      end
    end
  end
end