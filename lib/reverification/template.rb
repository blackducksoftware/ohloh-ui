# rubocop:disable Metrics/MethodLength, Metrics/ClassLength, Metrics/LineLength
module Reverification
  class Template
    class << self
      delegate :url_helpers, to: 'Rails.application.routes'

      def final_warning_notice(email)
        {
          source: Reverification::Mailer::FROM,
          destination: { to_addresses: [email.to_s] },
          message: {
            subject: {
              data: 'Your Account Will Be Deleted In Two Weeks: Please Reverify'
            },
            body: {
              html: {
                data: "<p>Hello;<br><br>
                  This is the fourth and final notice from the Black Duck OpenHub about reverifying your account.
                  Without an immediate response, your account will be permanently deleted within the next two weeks.
                  To prevent your account from being permanently deleted, please contact us at
                  <a href='mailto:info@openhub.net'>info@openhub.net</a>.<br><br>
                  We understand that this can seem severe and ask for your understanding as we continue to provide
                  the OpenHub as a free and open service to the Open Source Software community.
                  If you would like more background on this issue, we invite you to read our blog postings,
                  <a href='http://blog.openhub.net/2015/02/spammers_heaven/'>Oh dear, we’ve built a spammers heaven</a> and
                  <a href='http://blog.openhub.net/2015/08/new-accounts-are-back-but-so-are-the-spammers/'>New
                  Accounts are Back. But so are the spammers.</a><br><br> We thank you for your understanding and for being a
                  member of the OpenHub and the Open Source Software community.
                  <br><br>Sincerely,<br><br>The Black Duck OpenHub Team<br><br>Black Duck Software<br>
                  781.891.5100<br>8 New England Executive Park<br>Burlington, MA 01803<br>
                  <a href='https://www.openhub.net'>www.openhub.net</a></p>"
              }
            }
          }
        }
      end

      def account_is_disabled_notice(email)
        {
          source: Reverification::Mailer::FROM,
          destination: { to_addresses: [email.to_s] },
          message: {
            subject: {
              data: 'Your OpenHub Account has been deactivated.'
            },
            body: {
              html: {
                data: "<p>Hello;<br><br>You are receiving this notice because there has been
                  no response to the previous two notices sent to this email address about reverifying
                  your account on the OpenHub, which used to be Ohloh and this account has been deactivated.
                  At this point, it is not possible to access the account on the OpenHub.
                  At some point in the next few months, this account will be deleted permanently.
                  If you feel that this has been done in error, please contact us immediately at
                  <a href='mailto:info@openhub.net'>info@openhub.net</a> so that
                  we may restore the account and give you the opportunity to verify the account.
                  We understand that this can seem severe and ask for your understanding as we continue to provide
                  the OpenHub as a free and open service to the Open Source Software community.
                  If you would like more background on this issue, we invite you to read our blog postings,
                  <a href='http://blog.openhub.net/2015/02/spammers_heaven/'>Oh dear, we’ve built a spammers heaven</a> and
                  <a href='http://blog.openhub.net/2015/08/new-accounts-are-back-but-so-are-the-spammers/'>New
                  Accounts are Back. But so are the spammers.</a><br><br>
                  We thank you for your understanding and for being a member of the
                  OpenHub and the Open Source Software community.
                  <br><br>Sincerely,<br><br>The Black Duck OpenHub Team<br><br>Black Duck Software<br>
                  781.891.5100<br>8 New England Executive Park<br>Burlington, MA 01803<br>
                  <a href='https://www.openhub.net'>www.openhub.net</a></p>"
              }
            }
          }
        }
      end

      def marked_for_disable_notice(email)
        {
          source: Reverification::Mailer::FROM,
          destination: { to_addresses: [email.to_s] },
          message: {
            subject: {
              data: 'Your OpenHub account will be flagged for deactivation'
            },
            body: {
              html: {
                data: "<p>Hello Again;<br><br>
                  This is a second request from the Black Duck OpenHub, which used to be Ohloh,
                  that you reverify your account. Reverification requires the use of an SMS capable
                  phone number or a GitHub account. Please note the OpenHub will <bold>not</bold>
                  retain any personal information; neither your phone number or access to any information
                  in your GitHub account. These services are being used solely to verify users behind the
                  accounts on the OpenHub.<br><br>Please click on this #{verify_link} within 2 weeks so
                  that you may continue to have access to your account on the OpenHub.<br><br>
                  Please note that all accounts that are not reverified will be deactivated and permanently
                  deleted within a few months. We understand that this can seem severe and ask
                  for your understanding as we continue to provide the OpenHub as a free and open
                  service to the Open Source Software community. If you would like more background on this issue,
                  we invite you to read our blog postings, <a href='http://blog.openhub.net/2015/02/spammers_heaven/'>
                  Oh dear, we’ve built a spammers heaven</a> and
                  <a href='http://blog.openhub.net/2015/08/new-accounts-are-back-but-so-are-the-spammers/'>New
                  Accounts are Back. But so are the spammers.</a><br><br>We thank you for your understanding
                  and for being a member of the OpenHub and the Open Source Software community.<br><br>
                  Sincerely,<br><br>The Black Duck OpenHub Team<br><br>Black Duck Software<br>
                  781.891.5100<br>8 New England Executive Park<br>Burlington, MA 01803<br>
                  <a href='https://www.openhub.net'>www.openhub.net</a></p>"
              }
            }
          }
        }
      end

      def first_reverification_notice(email)
        {
          source: Reverification::Mailer::FROM,
          destination: { to_addresses: [email.to_s] },
          message: {
            subject: {
              data: 'Please Reverify Your Open Hub Account'
            },
            body: {
              html: {
                data: "<p>Hello;<br><br>As an effort to eliminate excessive spam accounts
                  in the Black Duck OpenHub (which used to be Ohloh.net), we are asking all account
                  holders to reverify their account. Reverification requires the use of an
                  SMS capable phone number or a GitHub account. Please note that the OpenHub will
                  <bold>not</bold> retain any personal information. Specifically, the OpenHub will neither retain your
                  phone number nor will the OpenHub have any access to your GitHub account. These services are
                  solely for the purpose of verifying users behind the accounts on the OpenHub<br><br>Please click on
                  this #{verify_link} within 2 weeks so that you may continue to have access to your account
                  on the OpenHub.<br><br>Please note that all accounts that are not reverified will be deactivated
                  and permanently deleted within a few months. We understand that this can seem severe and ask
                  for your understanding as we continue to provide the OpenHub as a free and open service to the
                  Open Source Software community. If you would like more background on this issue, we invite you
                  to read our blog postings, <a href='http://blog.openhub.net/2015/02/spammers_heaven/'>Oh dear,
                  we’ve built a spammers heaven</a> and
                  <a href='http://blog.openhub.net/2015/08/new-accounts-are-back-but-so-are-the-spammers/'>New
                  Accounts are Back. But so are the spammers.</a><br><br>We thank you for your understanding
                  and for being a member of the OpenHub and the Open Source Software community.<br><br>
                  Sincerely,<br><br>The Black Duck OpenHub Team<br><br>Black Duck Software<br>
                  781.891.5100<br>8 New England Executive Park<br>Burlington, MA 01803<br>
                  <a href='https://www.openhub.net'>www.openhub.net</a></p>"
              }
            }
          }
        }
      end

      def verify_link
        "<a href=#{url_helpers.new_authentication_url(host: ENV['URL_HOST'])}>reverification link</a>"
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/ClassLength, Metrics/LineLength
