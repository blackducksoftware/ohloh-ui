# frozen_string_literal: true

module GithubHelper
  def github_data_attributes
    { data: { client_id: ENV['GITHUB_CLIENT_ID'],
              redirect_uri: ENV['GITHUB_REDIRECT_URI'],
              scope: ENV['GITHUB_OAUTH_SCOPE'] } }
  end
end
