# frozen_string_literal: true

require 'test_helper'

describe 'Api::V1::EnlistmentsControllerTest' do
  include JWTHelper

  before do
    WebMocker.get_code_location
    @enlistment = create_enlistment_with_code_location
    @project_id = @enlistment.project_id
    @account = create(:account)
    @jwt = build_jwt('notalex', 24)
  end

  describe 'unsubscribe' do
    it 'should remove the enlistment' do
      byebug
      @enlistment.deleted.must_equal false
      #@code_location = @enlistment.code_location

      #CodeLocationSubscription.code_location_exists?(@project_id, @code_location.url,
      #  @code_location.branch, 'git').must_equal true

      post(
        :unsubscribe,
        JWT: @jwt,
        url: @enlistment.code_location.url,
        branch: @enlistment.code_location.branch,
        format: :json
      )
      response.must_be :success?
      #CodeLocationSubscription.code_location_exists?(@project_id, @code_location.url,
      #  @code_location.branch, 'git').must_equal false
      byebug
      @enlistment.reload.deleted.must_equal true
    end
  end

  #
  #    it 'must return errors when code location is not valid' do
  #      post :unsubscribe, JWT: JWT, url: @enlistment.url, branch: '', format: :json
  #      response.wont_be :success?
  #      assert true
  #    end

  #    it 'must return errors when the enlistment doesnt exist for the code_location' do
  #      post :unsubscribe, JWT: JWT, url: @enlistment.url, branch: '', format: :json

  #      response.wont_be :success?
  #      assert true
  #    end
end
