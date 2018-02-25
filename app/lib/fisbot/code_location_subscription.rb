class CodeLocationSubscription < FisbotApi
  class << self
    def endpoint
      :subscriptions
    end

    def code_locations_for_project(project_id)
      uri = URI("#{api_uri}/api/v1/subscriptions/code_locations/#{project_id}.json?api_key=#{api_key}")
      array = JSON.parse(Net::HTTP.get(uri))
      array.map { |hsh| CodeLocation.new(hsh) }
    end

    def code_location_ids_matching_forge(m)
      query_params = { api_key: api_key, forge_id: m.forge.id, name_at_forge: m.name_at_forge,
                       owner_at_forge: m.owner_at_forge }.to_query
      uri = URI("#{api_uri}/api/v1/subscriptions/matching_code_location_ids.json?#{query_params}")
      JSON.parse(Net::HTTP.get(uri))
    end

    def code_location_exists?(project_id, url, branch, scm_type)
      query_params = { api_key: api_key, url: url, branch: branch, scm_type: scm_type }.to_query
      uri = URI("#{api_uri}/api/v1/subscriptions/code_location_exists/#{project_id}.json?#{query_params}")
      Net::HTTP.get(uri) == '1'
    end

    def api_uri
      FisbotApi::API_URI
    end

    def api_key
      FisbotApi::API_KEY
    end
  end
end
