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
    @jwt = build_jwt(@account.login, 24)
    Enlistment.any_instance.stubs(:update_subscription).returns(true)
    Project.any_instance.stubs(:guess_forge).returns(@enlistment.project.forge_match)
    Enlistment.any_instance.stubs(:ensure_forge_and_job).returns(true)
  end

  describe 'unsubscribe' do
    it 'should remove the enlistment' do
      @enlistment.deleted.must_equal false
      post(
        :unsubscribe,
        JWT: @jwt,
        url: @url,
        branch: 'master',
        format: :json
      )
      response.must_be :success?
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

  describe 'enlist' do
    it 'should create the enlistment' do
      post(
        :enlist,
        JWT: @jwt,
        url: @url,
        branch: 'master',
        project: @project_id,
        format: :json
      )
      response.must_be :success?
      @enlistment = Enlistment.where(project_id: @project_id, url: @url, branch: 'master')
    end

    it 'must return errors when code location is not valid' do
      post(
        :enlist,
        JWT: @jwt,
        url: 'https://notacodelocation.biz',
        branch: 'master',
        project: @project_id,
        format: :json
      )
      response.wont_be :success?
    end

    it 'must return errors when project is not valid' do
      post(
        :enlist,
        JWT: @jwt,
        url: @url,
        branch: 'master',
        project: '4938409',
        format: :json
      )
      response.wont_be :success?
    end

    it 'must return an error when given a bad JWT' do
      post(
        :enlist,
        JWT: 'eyJhbGciOiJIUzI1.eyJleHBpcmF0aW9uIjoxNjMzMDI1NTcyLCJYWxleCJ9.whiDvp2KfeblCcMRnyskt7nehEcYKP5kEejkugIa0ko',
        url: @url,
        branch: 'master',
        project: @project_id,
        format: :json
      )
      response.wont_be :success?
    end
  end
end
