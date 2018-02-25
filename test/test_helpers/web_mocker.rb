module WebMocker
  extend WebMock::API

  module_function

  def get_code_location(id = 42)
    stub_request(:get, code_locations_url(id)).to_return(body: code_location_params(id: id).to_json)
  end

  def create_code_location(status = 201, hsh = {})
    stub_request(:post, code_locations_url).to_return(body: code_location_params(hsh).to_json, status: status)
  end

  def create_another_code_location(url)
    hsh = code_location_params
    hsh[:id] = Faker::Number.number(3)
    hsh[:url] = url.sub('https?', 'git')
    stub_request(:post, code_locations_url).to_return(body: hsh.to_json, status: 201)
  end

  def code_location_exists(record_exists)
    response_body = record_exists ? '1' : '0'
    stub_request(:get, %r{#{api_url}/subscriptions/code_location_exists/\d+.json\?#{api_key_param}.+url})
      .to_return(body: response_body)
  end

  def get_project_code_locations(valid_result = true, hsh = {})
    response_body = valid_result ? [code_location_params(hsh)] : []
    stub_request(:get, %r{#{api_url}/subscriptions/code_locations/\d+.json\?#{api_key_param}})
      .to_return(body: response_body.to_json)
  end

  def create_subscription
    stub_request(:post, "#{api_url}/subscriptions.json").to_return(body: 'Subscription Added Successfully')
  end

  def create_code_location_url_failure
    stub_request(:post, code_locations_url)
      .to_return(body: { error: { url: 'Either URL or branch parameter is missing' } }.to_json, status: 400)
  end

  def scm_type_count(expected_response)
    stub_request(:get, "#{api_url}/code_locations/scm_type_count.json?#{api_key_param}")
      .to_return(body: expected_response.to_json)
  end

  def code_location_find_by_failure(branch_name)
    stub_request(:get, "#{api_url}/code_locations/find_by.json?#{api_key_param}&branch=#{branch_name}")
      .to_return(body: 'long html backtrace', status: 500)
  end

  # ---- private ----

  def api_url
    "#{ENV['FISBOT_API_URL']}/api/v1"
  end

  def api_key
    ENV['FISBOT_CLIENT_REGISTRATION_ID']
  end

  def api_key_param
    "api_key=#{api_key}"
  end

  def code_locations_url(id = nil)
    return "#{api_url}/code_locations.json" unless id
    "#{api_url}/code_locations/#{id}.json?#{api_key_param}"
  end

  def rails_git_url
    'git://github.com/rails/rails'
  end

  def code_location_params(id: 42, best_code_set_id: nil)
    { id: id, scm_type: :git, url: rails_git_url, branch: :master,
      best_code_set_id: best_code_set_id, do_not_fetch: false, status: :active }
  end
end
