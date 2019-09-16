# frozen_string_literal: true

class GithubVerification < Verification
  validates :token, presence: true
end
