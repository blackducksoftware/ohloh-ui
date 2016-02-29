require 'test_helper'

class Reverification::MailerTest < ActiveSupport::TestCase
  class HardBounceBody
    def body_message_as_h
      { 'bounce': { 'bounceType': 'Permanent',
                    'bouncedRecipients': [{ 'emailAddress': 'bounce@simulator.amazonses.com' }]
        }
      }.with_indifferent_access
    end
  end

  class HardBounceMessage
    def as_sns_message
      HardBounceBody.new
    end
  end

  class SuccessBody
    def body_message_as_h
      { 'delivery':
          { 'recipients': ['success@simulator.amazonses.com'] }
      }.with_indifferent_access
    end
  end

  class SuccessMessage
    def as_sns_message
      SuccessBody.new
    end
  end

  class TransientBounceBody
     def body_message_as_h
       { 'bounce': { 'bounceType': 'Transient',
                     'bouncedRecipients': [{ 'emailAddress': 'ooto@simulator.amazonses.com' }]
         }
       }.with_indifferent_access
     end
   end

  class TransientBounceMessage
    def as_sns_message
      TransientBounceBody.new
    end

    def body
      'ooto@simulator.amazonses.com'
    end
  end
end