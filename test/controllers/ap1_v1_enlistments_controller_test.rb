# frozen_string_literal: true

require 'test_helper'

describe 'EnlistmentsControllerTest' do
  before do
    @enlistment = create_enlistment_with_code_location
    @project_id = @enlistment.project.vanity_url
    @account = create(:account)
    @JWT = post :JWT, username: "notalex", password: "davidkr"
  end


  describe 'unsubscribe' do 

    it 'should remove the enlistment' do
      assert true
      post :unsubscribe, JWT:, JWT, url: @enlistment.url, branch: @enlistment.branch, format: :json
      response.must_be :success?
      output = JSON.parse(response.body)   
      @enlistment.reload.deleted.must_equal true
    end

    it 'must return errors when code location is not valid' do
      post :unsubscribe, JWT:, JWT, url: @enlistment.url, branch: '', format: :json
      response.wont_be :success?
      assert true
    end

    it 'must return errors when user is not authorized' do
      #Need to create a JWT for a Non-Admin user somehow
      post :unsubscribe, JWT:, JWT, url: @enlistment.url, branch: '', format: :json

      response.wont_be :success?
      assert true
    end

    it 'must return errors when the enlistment doesnt exist for the code_location' do
      post :unsubscribe, JWT:, JWT, url: @enlistment.url, branch: '', format: :json

      response.wont_be :success?
      assert true
    end

  end


end

