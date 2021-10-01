# frozen_string_literal: true

require 'test_helper'

describe 'Api::V1::EnlistmentsControllerTest' do
  include JWTHelper

  before do
    WebMocker.get_code_location
    @url = Faker::Internet.url
    @enlistment = create_random_enlistment(@url)
    @project_id = @enlistment.project_id
    @account = create(:account)
    @jwt = build_jwt('notalex', 24)
  end

  describe 'unsubscribe' do
    it 'should remove the enlistment' do
      @enlistment.deleted.must_equal false
      # @code_location = @enlistment.code_location

      # CodeLocationSubscription.code_location_exists?(@project_id, @code_location.url,
      # @code_location.branch, 'git').must_equal true

      post(
        :unsubscribe,
        JWT: @jwt,
        url: @url,
        branch: 'master',
        format: :json
      )
      response.must_be :success?
      # CodeLocationSubscription.code_location_exists?(@project_id, @code_location.url,
      #  @code_location.branch, 'git').must_equal false
      @enlistment.reload.deleted.must_equal true
    end
  end

  it 'must return errors when code location is not valid' do
    post(
      :unsubscribe,
      JWT: @jwt,
      url: 'https://notacodelocation.biz',
      branch: 'master',
      format: :json
    )
    response.wont_be :success?
  end

  it 'must return an error when given a bad JWT' do
    post(
      :unsubscribe,
      JWT: 'eyJhbGciOiJIUzI1.eyJleHBpcmF0aW9uIjoxNjMzMDI1NTcyLCJYWxleCJ9.whiDvp2KfeblCcMRnyskt7nehEcYKP5kEejkugIa0ko',
      url: @url,
      branch: 'master',
      format: :json
    )
    response.wont_be :success?
  end
end
