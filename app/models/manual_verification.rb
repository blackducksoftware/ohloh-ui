# frozen_string_literal: true

class ManualVerification < Verification
  belongs_to :account, optional: true
end
