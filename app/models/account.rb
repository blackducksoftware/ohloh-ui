class Account < ActiveRecord::Base
  DEFAULT_LEVEL = 0
  ADMIN_LEVEL   = 10
  DISABLE_LEVEL = -10
  SPAMMER_LEVEL = -20
end
