class ReverificationPilotAccount < ActiveRecord::Base
  belongs_to :account
  TOTAL_SAMPLES = 5000
end
