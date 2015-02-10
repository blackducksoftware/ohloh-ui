require 'test_helper'

describe InvitesController do
  let(:invite)  { create(:invite) }
  let(:user)    { accounts(:user) }

  it 'new invite requires login' do
    get :new, contributor_id: invite.contribution_id
    must_respond_with :unauthorized
  end

  it 'new invite render the form' do
    login_as user
    get :new, contributor_id: invite.contribution_id
    must_respond_with :success
  end

  # it 'should send the invite' do
  #   login_as user
  #   post :create, contributor_id: invite.contribution_id, invite: { invitee_email: 'abc@yahoo.com' }
  #   must_respond_with :redirect
  #   flash[:success].must_equal I18n.t('invites.thank_you_message', name: assigns(:invite).name.name,
  #     email: assigns(:invite).invitee_email)
  # end

end
