# frozen_string_literal: true

require 'test_helper'

class AboutsControllerTest < ActionController::TestCase
  it 'get markdown_syntax view' do
    get :markdown_syntax
    assert_response :success
  end

  it 'get tools view' do
    @languages = create_list(:language, 5)
    get :tools
    assert_response :ok
    assert_template 'abouts/tools'
    _(assigns(:languages).count).must_equal 5
  end

  it 'gets site maintenance view' do
    get :maintenance
    assert_response :ok
    assert_template 'abouts/maintenance'
  end
end
