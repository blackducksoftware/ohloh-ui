# frozen_string_literal: true

require 'test_helper'

describe 'AboutsController' do
  it 'get markdown_syntax view' do
    get :markdown_syntax
    assert_response :success
  end

  it 'get tools view' do
    @languages = create_list(:language, 5)
    get :tools
    must_respond_with :ok
    must_render_template 'abouts/tools'
    assigns(:languages).count.must_equal 5
  end

  it 'gets site maintenance view' do
    get :maintenance
    must_respond_with :ok
    must_render_template 'abouts/maintenance'
  end
end
