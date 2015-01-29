class InvitesController < ApplicationController
  private

  def invite_params
    params.require(:invite).permit(:invitee_email, :contribution, :invitor)
  end
end
