# frozen_string_literal: true

module WebMocker
  extend WebMock::API

  module_function

  def get_code_location(id = 42)
    stub_request(:get, code_locations_url(id)).to_return(body: code_location_params(id: id).to_json)
  end

  def create_code_location(status = 201, hsh = {})
    stub_request(:post, code_locations_url).to_return(body: code_location_params(hsh).to_json, status: status)
  end

  def create_subscriptions_for_code_locations(status = 201, hsh = {})
    stub_request(:post, subscriptions_url).to_return(body: subscription_params(hsh).to_json, status: status)
  end

  def create_another_code_location(url)
    hsh = code_location_params
    hsh[:id] = Faker::Number.number(digits: 3)
    hsh[:url] = url.sub('https?', 'git')
    stub_request(:post, code_locations_url).to_return(body: hsh.to_json, status: 201)
  end

  def code_location_exists(record_exists)
    response_body = record_exists ? '1' : '0'
    url_with_stub = subscriptions_api.resource_uri('code_location_exists/42').to_s
    stub_request(:get, %r{#{url_with_stub.sub('42', '\d+').sub('?', '\?')}.+url})
      .to_return(body: response_body)
  end

  # rubocop:disable Style/OptionalBooleanParameter
  def get_project_code_locations(valid_result = true, hsh = {})
    response_body = valid_result ? [code_location_params(hsh)] : []
    url_with_stub = subscriptions_api.resource_uri('code_locations/42').to_s
    stub_request(:get, %r{#{url_with_stub.sub('42', '\d+').sub('?', '\?')}})
      .to_return(body: response_body.to_json)
  end
  # rubocop:enable Style/OptionalBooleanParameter

  def code_location_valid(valid_url: true)
    error_message = 'The URL does not appear to be a valid server connection string.'
    expected_response = valid_url ? '' : { error: { url: [error_message] } }
    status = valid_url ? 200 : 400
    stub_request(:post, code_locations_url(:valid)).to_return(body: expected_response.to_json, status: status)
  end

  def create_subscription
    stub_request(:post, subscriptions_api.resource_uri)
      .to_return(body: 'Subscription Added Successfully')
  end

  def delete_subscription(code_location_id, client_relation_id)
    stub_request(:delete, subscriptions_api.resource_uri("#{code_location_id}/#{client_relation_id}"))
      .to_return(body: 'Subscription Deleted Successfully')
  end

  def create_code_location_url_failure
    stub_request(:post, code_locations_url)
      .to_return(body: { error: { url: 'Either URL or branch parameter is missing' } }.to_json, status: 400)
  end

  def scm_type_count(expected_response)
    stub_request(:get, code_locations_api.resource_uri(:scm_type_count))
      .to_return(body: expected_response.to_json)
  end

  def code_location_find_by_failure(branch_name)
    stub_request(:get, code_locations_api.resource_uri(:find_by, branch: branch_name))
      .to_return(body: 'long html backtrace', status: 500)
  end

  def github_api(url, html_url)
    body = { id: Faker::Number.number(digits: 3), default_branch: 'master', html_url: html_url,
             homepage: Faker::Internet.url, name: Faker::Company.name }
    stub_request(:get, url).to_return(body: body.to_json)
  end

  # ---- private ----

  def subscriptions_api
    ApiAccess.new(:subscriptions)
  end

  def code_locations_api
    ApiAccess.new(:code_locations)
  end

  def code_locations_url(id = nil)
    code_locations_api.resource_uri(id)
  end

  def subscriptions_url(id = nil)
    subscriptions_api.resource_uri(id)
  end

  def rails_https_url
    'https://github.com/rails/rails'
  end

  def code_location_params(id: 42, best_code_set_id: nil)
    { id: id, scm_type: :git, url: rails_https_url, branch: :main,
      best_code_set_id: best_code_set_id, do_not_fetch: false, status: :active }
  end

  def subscription_params(id: 1, code_location_id: 42)
    { id: id, code_location_id: code_location_id, client_relation_id: 22 }
  end
end
