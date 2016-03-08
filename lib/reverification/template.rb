module Reverification
  class Template
    class << self
      def final_warning_notice(email)
        { to: "#{email}", from: Reverification::Mailer::FROM,
          subject: 'Your Account Will Be Deleted Tomorrow: Please Reverify',
          body_html: "Hello, you are receiving this notice because Open Hub has determined that this account is spam
            and will be deleted from the website in 2 weeks. If this is incorrect, please click on the reverification
            link <a href=#{ENV['URL_HOST']}/authentications/new /> in order to restore your account. Failure to do so
            within the 2 weeks time span will result in your account's deletion and will no longer be able to be
            restored. Please reverify your account by tomorrow so that you may continue to enjoy our services.<br/>
            Sincerely,<br/>
            The Open Hub Team
            8 New England Executive Park, Burlington, MA 01803" }
      end

      def account_is_spam_notice(email)
        { to: "#{email}", from: Reverification::Mailer::FROM, subject: 'Your Account Status Has Converted to Spam',
          body_html: "Hello, you are receiving this notice because Open Hub has determined that this account is spam
            and has changed the status of your account to spam in its system. If this is incorrect, please click
            on the reverification link <a href=#{ENV['URL_HOST']}/authentications/new /> in order to restore your accoun
            t. Failure to do so will result in your account's eventual deletion. Please reverify your account within 2
            weeks so that you may continue to enjoy our services. Please note that if you fail to verify within the 2
            weeks period, your account and all data associated it will be marked for deletion.<br/>
            Sincerely,<br/>
            The Open Hub Team
            8 New England Executive Park, Burlington, MA 01803" }
      end

      def marked_for_spam_notice(email)
        { to: "#{email}", from: Reverification::Mailer::FROM,
          subject: 'Account Marked for Spam',
          body_html: "As an effort to eliminate excessive spam accounts, Open Hub has provided you the following link
            in order to reverify your account with us. Please click on the reverification link
            <a href=#{ENV['URL_HOST']}/authentications/new /> within 2 weeks so that you may continue to enjoy our
            services. Please note that if you fail to verify your account within the 2 weeks time span, Open Hub will
            convert your account status as spam. Thank you.<br/>
            Sincerely,<br/>
            The Open Hub Team
            8 New England Executive Park, Burlington, MA 01803" }
      end

      def first_reverification_notice(email)
        { to: "#{email}", from: Reverification::Mailer::FROM,
          subject: 'Please Reverify Your Open Hub Account',
          body_html: "As an effort to eliminate excessive spam accounts, Open Hub has provided you the following link
            in order to reverify your account with us. Please click on the reverification link
            <a href=#{ENV['URL_HOST']}/authentications/new /> within 2 weeks so that you may continue to enjoy our
            services. Please note that if you fail to verify your account within 2 weeks, Open Hub will flag your
            account as spam. Thank you.<br/>
            Sincerely,<br/>
            The Open Hub Team
            8 New England Executive Park, Burlington, MA 01803" }
      end
    end
  end
end
