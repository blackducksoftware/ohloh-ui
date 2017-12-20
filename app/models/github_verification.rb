class GithubVerification < Verification
  validates :token, presence: true
end
