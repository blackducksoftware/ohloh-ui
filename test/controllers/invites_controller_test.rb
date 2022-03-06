# frozen_string_literal: true

require 'test_helper'

class InvitesControllerTest < ActionController::TestCase
  let(:user) { create(:account) }
  let(:invite) { build(:invite) }

  it 'new invite requires login' do
    get :new, params: { contributor_id: invite.contribution.id }
    assert_response :redirect
    assert_redirected_to new_session_path
  end

  it 'new invite render the form' do
    login_as user
    get :new, params: { contributor_id: invite.contribution.id }
    assert_response :success
  end

  it 'should create the invite' do
    login_as user
    assert_difference('Invite.count', 1) do
      post :create, params: { contributor_id: invite.contribution.id, invite: { invitee_email: 'abc@yahoo.com' } }
    end
    _(assigns(:invite).success_flash).must_equal I18n.t('invites.thank_you_message', name: assigns(:invite).name.name,
                                                                                     email: 'abc@yahoo.com')
    assert_redirected_to project_contributor_path(assigns(:invite).project, assigns(:invite).contribution_id)
  end

  it 'shouldn\'t create a duplicate invite' do
    login_as user
    post :create, params: { contributor_id: invite.contribution.id, invite: { invitee_email: 'abc@yahoo.com' } }
    assert_no_difference('Invite.count') do
      post :create, params: { contributor_id: invite.contribution.id, invite: { invitee_email: 'abc@yahoo.com' } }
    end
  end
end
