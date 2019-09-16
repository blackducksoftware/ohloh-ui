# frozen_string_literal: true

class DeletedAccountsController < ApplicationController
  before_action :set_deleted_account
  before_action :feedback_time_must_not_be_elapsed
  before_action :account_must_be_deleted

  def update
    if params[:reasons].present?
      processed_reasons = process_reason_params(params)
      @deleted_account.update(reasons: processed_reasons[:reasons], reason_other: processed_reasons[:other])
      redirect_to root_path, flash: { success: t('.success') }
    else
      render 'edit'
    end
  end

  private

  def process_reason_params(params)
    { reasons: "{#{params[:reasons].join(',')}}", other: String.clean_string(params[:reason_other]) }
  end

  def set_deleted_account
    @deleted_account = DeletedAccount.find_deleted_account(params[:id])
    raise ParamRecordNotFound unless @deleted_account
  end

  def feedback_time_must_not_be_elapsed
    redirect_to root_path, flash: { error: t('.expired') } if @deleted_account.feedback_time_elapsed?
  end

  def account_must_be_deleted
    redirect_to root_path, flash: { error: t('.invalid_request') } if Account.find_by(login: params[:id])
  end
end
