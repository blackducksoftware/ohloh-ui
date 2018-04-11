class CodeLocationSubscription < FisbotApi
  class << self
    def resource
      :subscriptions
    end

    def code_locations_for_project(project_id)
      uri = api_access.resource_uri("code_locations/#{project_id}")
      array = JSON.parse(Net::HTTP.get(uri))
      array.map { |hsh| CodeLocation.new(hsh) }
    end

    def code_location_exists?(project_id, url, branch, scm_type)
      query_params = { url: url, branch: branch, scm_type: scm_type }
      uri = api_access.resource_uri("code_location_exists/#{project_id}", query_params)
      Net::HTTP.get(uri) == '1'
    end
  end
end
