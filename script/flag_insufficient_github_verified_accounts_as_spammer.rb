#! /usr/bin/env ruby

require_relative '../config/environment'
require 'logger'

class FlagInsufficientGithubVerifiedAccounts
  GITHUB_USER_URL = 'https://api.github.com/users/'.freeze
  GITHUB_CURRENT_USER_URL = 'https://api.github.com/user'.freeze

  def initialize
    @log = Logger.new('log/github_verified_spammer.log')
  end

  def execute
    date = Time.zone.parse('20171221200129') # Github login deployment date

    GithubVerification.includes(:account).where('verifications.created_at > ?', date)
                      .where.not(accounts: { level: Account::Access::SPAM }).each do |verification|
      response = user_response(verification)

      mark_account_as_spammer(verification.account) if response['login'].nil? || invalid_github_account?(response)
    end
  end

  private

  def get_response(url, params = {})
    params[:client_id] = ENV['GITHUB_CLIENT_ID']
    params[:client_secret] = ENV['GITHUB_CLIENT_SECRET']
    uri = URI(url + "?#{params.to_query}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.get2(uri.request_uri)
    JSON.parse(response.body)
  end

  def user_response(verification)
    response = get_response(GITHUB_USER_URL + verification.unique_id.to_s)
    response = get_response(GITHUB_CURRENT_USER_URL, access_token: verification.unique_id) if response['login'].nil?
    response
  end

  def repository_has_language?(repo_uri)
    params = { type: :owner, sort: :pushed, per_page: GithubApi::REPO_LIMIT }
    repositories_response = get_response(repo_uri, params)

    repositories_response.any? do |repository_hash|
      repository_hash['language'].present?
    end
  end

  def created_at(response)
    Time.zone.parse(response['created_at'])
  end

  def invalid_github_account?(response)
    created_at(response) > 1.month.ago && !repository_has_language?(response['repos_url'])
  end

  def mark_account_as_spammer(account)
    @log.info "Marking #{account.login}(#{account.id}) as spammer"
    account.update_attribute(:level, Account::Access::SPAM)
  end
end

FlagInsufficientGithubVerifiedAccounts.new.execute
