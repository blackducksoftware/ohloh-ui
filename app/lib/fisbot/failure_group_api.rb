# frozen_string_literal: true

class FailureGroupApi < FisbotApi
  class << self
    def resource
      :failure_groups
    end

    def failure_group_description(job_id)
      uri = api_access.resource_uri("find_by_job/#{job_id}")
      response = JSON.parse(Net::HTTP.get(uri))
      response['description'] if response.present?
    end
  end
end
