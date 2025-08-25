# frozen_string_literal: true

module GithubHelper
  def github_data_attributes
    { data: { client_id: ENV.fetch('GITHUB_CLIENT_ID', nil),
              redirect_uri: ENV.fetch('GITHUB_REDIRECT_URI', nil),
              scope: ENV.fetch('GITHUB_OAUTH_SCOPE', nil) } }
  end
end
