# frozen_string_literal: true

require 'test_helper'

describe 'CodeopenhubController' do
  it 'should return 200 for index' do
    get :index
    assert_response :success
  end

  it 'should hit the code openhub page with a call to code.openhub.net/*' do
    get :index
    assert_response :success
  end
end
