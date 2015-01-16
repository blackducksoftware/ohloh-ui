require 'test_helper'

class AboutsControllerTest < ActionController::TestCase

  test "get markdown_syntax view" do
    get :markdown_syntax
    assert_response :success
  end
end