# frozen_string_literal: true

class GithubVerification < Verification
  validates :token, presence: true

  validates :unique_id, presence: true, uniqueness: true
end
