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

    def code_location_ids_matching_forge(m)
      query_params = { forge_id: m.forge.id, name_at_forge: m.name_at_forge, owner_at_forge: m.owner_at_forge }
      uri = api_access.resource_uri(:matching_code_location_ids, query_params)
      JSON.parse(Net::HTTP.get(uri))
    end

    def code_location_exists?(project_id, url, branch, scm_type)
      query_params = { url: url, branch: branch, scm_type: scm_type }
      uri = api_access.resource_uri("code_location_exists/#{project_id}", query_params)
      Net::HTTP.get(uri) == '1'
    end
  end
end
