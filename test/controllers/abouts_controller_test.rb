require 'test_helper'

describe 'AboutsController' do
  it 'get markdown_syntax view' do
    get :markdown_syntax
    assert_response :success
  end

  it 'get tools view' do
    get :tools
    must_respond_with :ok
    must_render_template 'abouts/tools'
  end

  # TODO: Messages and Maintenance not implemented but are referenced in view code.
end
