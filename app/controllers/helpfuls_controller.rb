# frozen_string_literal: true

class HelpfulsController < ApplicationController
  before_action :session_required, :redirect_unverified_account

  def create
    @helpful = Helpful.where(account_id: current_user.id,
                             review_id: params[:review_id]).first_or_initialize
    @helpful.account = current_user
    @helpful.yes = params[:yes].present? && params[:yes]
    @helpful.save
  end

  private

  def model_params
    params.require(:helpful).permit(:review_id)
  end
end
