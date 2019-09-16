# frozen_string_literal: true

# This exception is used in the app to distiguish between user generated ActiveRecord::RecordNotFound
# exceptions and ones generated internally. We do not want to jump on malformed URLs typed in by users
# (e.g. https://www.openhub.net/p/i_am_not_a_project), but do wish to alert and fix AR::RNF exceptions
# thrown by our internal code.
#
# To prevent Airbrake exceptions from bad URLs, in controllers, catch AR::RNF exceptions that come from
# request params and rethrow them as ParamRecordNotFound.
class ParamRecordNotFound < StandardError
end
