# frozen_string_literal: true

require 'test_helper'

class Admin::EnlistmentsControllerTest < ActionController::TestCase
  let(:admin) { create(:admin) }
  let(:account) { create(:account) }

  before do
    login_as admin
  end

  it 'should render index page' do
    create_enlistment_with_code_location
    get :index
    assert_response :success
  end

  it 'should edit the enlistment' do
    account.update_column(:level, 10)
    login_as account
    @enlistment = create_enlistment_with_code_location
    put :update, params: { id: @enlistment.id }
    _(assigns(:enlistment).valid?).must_equal true
  end

  it 'edit should populate the form' do
    account.update_column(:level, 10)
    login_as account
    @enlistment = create_enlistment_with_code_location
    get :edit, params: { id: @enlistment.id }
    assert_response :ok
  end
end
