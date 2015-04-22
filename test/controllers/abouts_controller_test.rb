require 'test_helper'

describe 'AboutsController' do
  test 'get markdown_syntax view' do
    get :markdown_syntax
    assert_response :success
  end
end
