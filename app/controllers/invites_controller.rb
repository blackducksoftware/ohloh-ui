class InvitesController < ApplicationController
  before_action :session_required
  before_action :find_contribution

  def create
    if @invite.save
      InviteMailer.send_invite(@invite).deliver_now
      # TODO: change the redirection once project contributor is implemented
      # redirect_to project_contributor_path(@invite.project, @invite.contribution_id)
      redirect_to accounts_path, flash: { sucess: @invite.success_flash } # temporary
    else
      render 'new'
    end
  end

  private

  def invite_params
    params.require(:invite).permit(:invitee_email, :invitor, :contribution)
  end

  def model_params
    invitee_email = params.try(:[], 'invite').try(:[], 'invitee_email')
    { invitee_email: invitee_email, contribution: @contribution, invitor: current_user }
  end

  def find_contribution
    @contribution = Contribution.find_by_id(params[:contributor_id])
    fail ParamRecordNotFound if @contribution.nil?
    @invite = Invite.new(model_params)
  end
end
