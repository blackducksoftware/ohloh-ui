# frozen_string_literal: true

require 'test_helper'

class FailureGroupApiTest < ActiveSupport::TestCase
  it 'should get the failure groups' do
    VCR.use_cassette('failure_groups_find_by_job', match_requests_on: [:path]) do
      api = FailureGroupApi.new.fetch
      assert JSON.parse(api)['description'] = 'No branch found'
    end
  end

  it 'should get the failure groups for given id' do
    VCR.use_cassette('failure_groups_find_by_job') do
      response = FailureGroupApi.failure_group_description(1)
      _(response).must_equal 'No branch found'
    end
  end
end
