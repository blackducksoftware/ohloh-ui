class InvitesController < ApplicationController
  before_action :session_required, :redirect_unverified_account
  before_action :find_contribution

  def create
    if @invite.save
      InviteMailer.send_invite(@invite).deliver_now
      flash[:success] = @invite.success_flash
      redirect_to project_contributor_path(@invite.project, @invite.contribution_id)
    else
      render 'new'
    end
  end

  private

  def model_params
    invitee_email = params[:invite] ? params[:invite][:invitee_email] : nil
    { invitee_email: invitee_email, contribution: @contribution, invitor: current_user }
  end

  def find_contribution
    @contribution = Contribution.find_by(id: params[:contributor_id])
    raise ParamRecordNotFound if @contribution.nil?

    @invite = Invite.new(model_params)
  end
end
